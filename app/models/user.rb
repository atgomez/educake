# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  first_name             :string(255)      not null
#  last_name              :string(255)      not null
#  phone                  :string(255)
#  classroom              :string(255)
#  role_id                :integer
#  parent_id              :integer
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  school_name            :string(255)
#  photo_file_name        :string(255)
#  photo_content_type     :string(255)
#  photo_file_size        :integer
#  photo_updated_at       :datetime
#  is_admin               :boolean
#

class User < ActiveRecord::Base
  include ::SharedMethods::Paging  
  attr_accessor :skip_password

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, 
  :last_name, :phone, :classroom, :school_name, :confirmed_at, :parent_id
  
  # ASSOCIATIONS
  has_many :children, :class_name => "User", :foreign_key => 'parent_id' 
  belongs_to :parent, :class_name => "User", :foreign_key => 'parent_id'  
  has_many :students, :foreign_key => "teacher_id", :dependent => :destroy
  has_many :student_sharings, :dependent => :destroy
  has_many :shared_students, :through => :student_sharings, :source => :student
  belongs_to :role

  has_attached_file :photo, :styles => { :small => "200x200>", :medium => "300x300>" }, 
                   :storage => :s3,
                   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                   :default_url => 'default-avatar.jpeg',
                   :path => "photos/users/:id/:style.:extension"

  # VALIDATION
  has_one :student_sharing
  validates_presence_of :first_name, :last_name
  validates_length_of :first_name, :maximum => 15
  validates_length_of :last_name, :maximum => 15

  # CALLBACK
  after_create :update_user_for_student_sharing

  # SCOPE
  
  # Get all users has the given role
  #
  # === Parameters
  #
  #   * role (String/Role): can a string or Role object
  #
  scope :with_role, lambda { |role|
    if role.is_a?(String) or role.is_a?(Symbol)
      role = Role.find_by_name(role.to_s.titleize)
    end
    
    if role
      where(:role_id => role.id)
    else
      self.limit(0) # Return an empty ActiveRecord::Relation
    end
  }

  # Supper admins
  scope :super_admins, where(:is_admin => true)
  
  # Admins
  scope :admins, lambda { self.with_role(:admin) }
  
  # Teachers
  scope :teachers, lambda { self.with_role(:teacher) }
  
  # Class methods
  class << self
    # Load data
    #
    # === Parameters
    #
    #   * params[:page_size]
    #   * params[:page_id]
    #
    def load_data(params = {})
      paging_info = parse_paging_options(params)
      # Paginate with Will_paginate.
      self.paginate(:page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string)
    end

    # Do a simple search
    #
    # === Parameters
    #
    #   * query(String): the query string
    #   * params[:page_size]
    #   * params[:page_id]
    #
    def search_data(query, params = {})
      return [] if query.blank?
      meta_keys = %w(email first_name last_name)

      meta_key = build_meta_search_query(meta_keys)
      meta_query = {meta_key => query}

      paging_info = parse_paging_options(params)
      
      return self.search(meta_query).paginate(:page => paging_info.page_id,
                      :per_page => paging_info.page_size,
                      :order => paging_info.sort_string)
    end

    def new_with_role_name(role_name, attrs)
      user = self.new(attrs)
      user.role = Role.find_by_name(role_name.to_s.titleize)
      return user
    end

    protected

      # Parse params to PagingInfo object.
      def parse_paging_options(options, default_opts = {})
        if default_opts.blank?
          # This conditions will order records by directory and name first.
          default_opts = {
            :sort_criteria => "first_name ASC, last_name ASC"
          }
        end
        paging_options(options, default_opts)
      end

      # Build query string for meta_search
      def build_meta_search_query(meta_keys)
        keys = meta_keys.join("_or_")
        keys << "_contains"
        return keys
      end

  end # End class methods.

  # Instance methods

  def accessible_students
    union_sql = %Q{
      (SELECT * FROM (#{self.students.to_sql}) d1
      UNION ALL 
      SELECT * FROM (#{self.shared_students.to_sql}) d2) #{Student.table_name}
    }
    Student.from(union_sql).select('*')
  end
  
  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def photo_url(style = :small)
    self.photo.url(style)
  end
  
  def update_user_for_student_sharing
    st_sharing = StudentSharing.find_by_email(self.email)
     
    if !st_sharing.blank? && st_sharing.user_id.blank?
      # For the new user.
      st_sharing.update_attribute(:user_id, self.id)
      parent_teacher = st_sharing.student.teacher
      parent_teacher_id = nil
      if parent_teacher.parent_id.blank?
        # Set the inviter as the parent teacher.
        parent_teacher_id = parent_teacher.id
      else
        parent_teacher_id = parent_teacher.parent_id
      end
      self.update_attributes({:confirmed_at => Time.now, :parent_id => parent_teacher_id})
    end
  end

  def teacher_status
    data = []
    progress = {}
    students = self.students
    students.each do |student|
      student_data = student.goals_statuses
      student_data.each do |single_data| 
        progress[single_data[0]] = [] if progress[single_data[0]].nil?
        progress[single_data[0]] << single_data[1]
      end
    end

    progress.keys.sort.each do |key| 
      data << [key, ((progress[key].sum/progress[key].count*100).round / 100.0)]
    end 
    return data
  end

  # Check user's role
  def is?(role_name)
    self.role.try(:name).to_s.downcase == role_name.to_s.downcase
  end

  # Check if user has no password
  def has_no_password?
    self.encrypted_password.blank?
  end

  def change_password(params)
    self.update_attributes({
      :password => params[:password],
      :password_confirmation => params[:password_confirmation]
    })
  end

  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

  # Just an alias for is_admin
  def is_super_admin?
    self.is_admin?
  end

  protected

    def password_required?
      return false if self.skip_password
      super
    end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  first_name             :string(255)      not null
#  last_name              :string(255)      not null
#  phone                  :string(255)
#  classroom              :string(255)
#  role_id                :integer
#  parent_id              :integer
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  school_name            :string(255)
#  photo_file_name        :string(255)
#  photo_content_type     :string(255)
#  photo_file_size        :integer
#  photo_updated_at       :datetime
#  is_admin               :boolean
#
