class User < ActiveRecord::Base
  include ::SharedMethods::Paging

  ROLES = %w[admin principal teacher parent]
  DUMMY_PASSWORD = "123456"

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, 
  :last_name, :phone, :classroom, :school_name, :role_id, :confirmed_at, :parent_id
  
  # ASSOCIATIONS
  has_many :children, :class_name => "User", :foreign_key => 'parent_id' 
  belongs_to :parent, :class_name => "User", :foreign_key => 'parent_id'  
  has_many :students, :foreign_key => "teacher_id", :dependent => :destroy
  has_many :student_sharings, :dependent => :destroy
  has_many :shared_students, :through => :student_sharings, :source => :student
  
  has_attached_file :photo, :styles => { :small => "200x200>", :medium => "300x300>" }, 
                   :storage => :s3,
                   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                   :default_url => 'default-avatar.jpeg',
                   :path => "photos/users/:id/:style.:extension"

  # VALIDATION
  has_one :student_sharing
  validates_presence_of :first_name, :last_name
  
  # CALLBACK
  after_create :update_user_for_student_sharing

  # Class methods
  class << self

    # Create new User object with default password in case of no password is specified.
    def new_with_default_password(attrs)
      attrs[:password] = DUMMY_PASSWORD if attrs[:password].blank?
      attrs[:password_confirmation] = DUMMY_PASSWORD if attrs[:password_confirmation].blank?
      self.new(attrs)
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

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def photo_url(style = :small)
    self.photo.url(style)
  end
  
  def update_user_for_student_sharing
    st_sharing = StudentSharing.find_by_email(self.email)
     
    unless st_sharing.blank?
      st_sharing.update_attribute(:user_id, self.id)
      self.update_attributes({:confirmed_at => Time.now, :parent_id => st_sharing.student.teacher.parent_id})
    end
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
#

