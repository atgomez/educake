# == Schema Information
#
# Table name: student_sharings
#
#  id            :integer          not null, primary key
#  first_name    :string(255)      not null
#  last_name     :string(255)      not null
#  email         :string(255)      not null
#  student_id    :integer          not null
#  user_id       :integer
#  role_id       :integer          not null
#  confirm_token :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class StudentSharing < ActiveRecord::Base
  include ::SharedMethods::SerializationConfig  

  attr_accessible :email, :first_name, :last_name, :student_id, :user_id, :role_id, :confirm_token, :is_blocked

  # ASSOCIATION
  belongs_to :student
  belongs_to :user
  belongs_to :role
  
  # VALIDATION
  validates :first_name, :last_name, :student_id, :email, :role_id, :presence => true
  validates_format_of :email, :with  => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, 
                      :allow_blank => true, :if => :email_changed?
  validates :email, :uniqueness => { :scope => [:student_id]}
  validate :cross_school_sharing
  validate :check_role

  validates_length_of :first_name, :maximum => 15
  validates_length_of :last_name, :maximum => 15
  validates_format_of :first_name, :with => /^[^0-9!@#\$%\^&*+_=]+$/
  validates_format_of :last_name, :with => /^[^0-9!@#\$%\^&*+_=]+$/

  # CALLBACK
  before_validation :detect_shared_user
  after_create :save_token
  

  scope :unblocked, where(:is_blocked => false)

  # 
  # Class methods
  #
  class << self
    # Names of attributes will be exposed when serializing object to JSON, XML, etc.
    def exposed_attributes
      [:id, :first_name, :last_name, :email, :role_id]
    end
  end

  #
  # Instance methods
  #

  def full_name
    [self.first_name, self.last_name].join(" ")
  end  

  # Check if the sharing is confirmed or not
  def confirmed?
    !self.user_id.blank?
  end
  
  protected

    def save_token 
      self.update_attribute(:confirm_token, Digest::SHA1.hexdigest(self.email))
      user = User.find_by_email(self.email)
      if user
        self.update_attribute(:user_id, user.id)
      end
    end

    # Check if user is trying to share to teacher of other school
    def cross_school_sharing
      if self.user
        if self.user && (self.user.school_id != self.student.teacher.school_id || 
                        self.user.id == self.student.teacher_id)
          self.errors.add(:email, :taken)
        end
      end
    end

    # Role is just for teacher, parent
    def check_role
      if !(Role.exists?(:id => self.role_id) && Role[:admin].id != self.role_id)
        self.errors.add(:role_id, :invalid)
      end
    end

    def detect_shared_user      
      tmp_user = User.unblocked.find_by_email(self.email)
      if tmp_user
        self.first_name = tmp_user.first_name
        self.last_name = tmp_user.last_name
        self.role_id = tmp_user.role_id
        self.user = tmp_user
      end
      return true
    end
end
