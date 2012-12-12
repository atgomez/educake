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
#  photo_file_name        :string(255)
#  photo_content_type     :string(255)
#  photo_file_size        :integer
#  photo_updated_at       :datetime
#  is_admin               :boolean          default(FALSE)
#  school_id              :integer
#  notes                  :text
#  is_blocked             :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class User < ActiveRecord::Base
  include ::SharedMethods::Paging  
  attr_accessor :skip_password
  
  NAME = 1
  SCHOOL = 2
  ROLE = 3
  TYPES_SEARCH = {NAME => "Name", SCHOOL => "School", ROLE => "Role"}

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name,
                  :last_name, :phone, :classroom, :confirmed_at, :parent_id, :notes, :role_id, :school_id
  
  # ASSOCIATIONS
  has_many :children, :class_name => "User", :foreign_key => 'parent_id' 
  belongs_to :parent, :class_name => "User", :foreign_key => 'parent_id'  

  # All students belong to the current users and students are shared to the current user.
  # TODO: this association does not work probably when calling like this: user.accessible_students.order("first_name")
  # has_many :accessible_students, :class_name => "Student", :foreign_key => "teacher_id",
  #          :finder_sql =>  Proc.new {
  #             union_sql = %Q{
  #               (SELECT * FROM (#{self.students.to_sql}) d1
  #               UNION ALL 
  #               SELECT * FROM (#{self.shared_students.to_sql}) d2) #{Student.table_name}
  #             }
  #             Student.from(union_sql).order("first_name ASC, last_name ASC").select('DISTINCT *').to_sql
  #           }

  has_one :student_sharing, :dependent => :destroy
  has_many :student_sharings, :dependent => :destroy
  has_many :shared_students, :through => :student_sharings, :source => :student
  has_many :students, :foreign_key => "teacher_id", :dependent => :destroy


  belongs_to :role
  belongs_to :school


  has_attached_file :photo, :styles => { :small => "200x200>", :medium => "300x300>" }, 
                   :storage => :s3,
                   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                   :default_url => 'default-avatar.jpeg',
                   :path => "photos/users/:id/:style.:extension"  

  # VALIDATION  
  validates_presence_of :first_name, :last_name, :email
  validates_presence_of :role, :unless => :is_super_admin?
  validates_presence_of :school_id, :if => :is_not_admin?
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
      role = Role[role]
    else 
      role = nil
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

  # Available
  scope :unblocked, where(:is_blocked => false) 

  # Class methods
  class << self
    def like_search(query, params = {})
      #results = []
      paging_info = parse_paging_options(params)
      # Paginate with Will_paginate.
      paginates = {:page => paging_info.page_id,
        :per_page => paging_info.page_size,
        :order => paging_info.sort_string}
      return self.paginate(paginates) if query.blank?
      search = query.split(' ', 2)
      
      if search.length > 1
        with_scope( :find => { :conditions => ['lower(first_name) LIKE ? and role_id IS NOT NULL', "%#{search[0].downcase}%"] }) do
          paginates = paginates.merge(:conditions => ['lower(last_name) LIKE ? and role_id IS NOT NULL', "%#{search[1].downcase}%"])
          return self.paginate(paginates)
        end
      elsif search.length == 1
        paginates = paginates.merge(:conditions => ['lower(first_name) LIKE ? or lower(last_name) LIKE ? and role_id IS NOT NULL', "%#{search[0].downcase}%", "%#{search[0].downcase}%"])
        return self.paginate(paginates)
      end
    end

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
      user.role = Role[role_name]
      return user
    end

    protected

      # Parse params to PagingInfo object.
      def parse_paging_options(options, default_opts = {})
        if default_opts.blank?
          # This conditions will order records by directory and name first.
          default_opts = {
            :sort_criteria => "users.first_name ASC, users.last_name ASC"
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

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, :to => :ability
  
  def accessible_students
    union_sql = %Q{
                (SELECT * FROM (#{self.students.to_sql}) d1
                UNION ALL 
                SELECT * FROM (#{self.shared_students.to_sql}) d2) #{Student.table_name}
              }
    Student.from(union_sql).select("DISTINCT students.*").order("students.first_name ASC, students.last_name ASC")
  end

  def goals
    Goal.joins("join (#{accessible_students.to_sql}) AS acc_students on acc_students.id = goals.student_id")
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def photo_url(style = :small)
    self.photo.url(style)
  end
  
  def update_user_for_student_sharing
    # Update token for user
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
    self.accessible_students.each do |student|
      student_data = student.goals_grades
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
    password_params = {}
    [:current_password, :password, :password_confirmation].each do |key|
      if params.has_key?(key)
        password_params[key] = params[key]
      end
    end
    
    unless password_params.blank?      
      if password_params[:current_password]
        # Update with requiring current_password
        self.update_with_password(password_params)
      else
        self.update_attributes({
          :password => password_params[:password],
          :password_confirmation => password_params[:password_confirmation]
        })
      end
    end
  end

  # Change user's profile
  #
  def update_profile(params)
    user_info = {}
    
    # Only allow update some fields
    [:first_name, :last_name, :phone, :photo].each do |key|
      if params.has_key?(key)
        user_info[key] = params[key]
      end
    end
    
    unless user_info.blank?
      self.update_without_password(user_info)
    end
  end

  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

  # Just an alias for is_admin
  def is_super_admin?
    self.is_admin?
  end
  
  def is_admin_school?
    self.is?(:admin)
  end
  
  def is_not_admin?
    !(is_admin_school? || is_super_admin?)
  end

  # Check on-track for teacher
  #
  # === Return:
  #
  #   * 0 : N/A (Not available)
  #   * 1 : on-track
  #   * 2 : not on-track
  #
  def check_on_track?
    result = 0
    
    self.accessible_students.each do |student|
      result = student.check_on_track?
      if result == 2
        # Not on-track
        break
      end
    end

    return result
  end

  # Skip password when validating.
  def skip_password!
    # Securely remove all password fields, otherwise user cannot confirm.
    self.password = nil
    self.password_confirmation = nil
    self.encrypted_password = ''
    self.skip_password = true
  end
  
  # EXPORTING

  # Collect data for charting

  def series_json(params={}, context)
    series = []
    if self.is?(:admin)
      teachers = self.children.teachers.unblocked
      teachers.map do |teacher|
        teacher_status = teacher.teacher_status
        series << {
          :name => teacher.full_name,
          :data => teacher_status,
          :yAxis => 2,
          :item_id => teacher.id,
          :url => context.students_path(:user_id => teacher.id)
        } unless teacher_status.empty?
      end
    else
      students = self.accessible_students.includes(:goals)
      students.map do |student|
        goals_grades = student.goals_grades
        series << {
          :name => student.full_name,
          :data => goals_grades,
          :yAxis => 2,
          :item_id => student.id,
          :url => context.student_path(student, :user_id => self.id)
        } unless goals_grades.empty?
      end
    end
    series.to_json
  end

  protected
 
    def password_required?
      return false if self.skip_password
      super
    end
end
