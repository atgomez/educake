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
  attr_accessible :email, :first_name, :last_name, :student_id, :user_id, :role_id, :confirm_token

  # ASSOCIATION
  belongs_to :student
  belongs_to :user
  belongs_to :role
  
  # VALIDATION
  validates :first_name, :last_name, :student_id, :email, :role_id, :presence => true
  validates_format_of :email, :with  => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true, :if => :email_changed?
  validates :email, :uniqueness => { :scope => [:student_id]}

  # CALLBACK
  after_create :save_token

  # Instance methods

  def full_name
    [self.first_name, self.last_name].join(" ")
  end  

  # Check if the sharing is confirmed or not
  def confirmed?
    !self.user_id.blank?
  end
  def self.get_invited_users(student_id)
    (self.joins(:user).select("student_sharings.*, users.*").where("student_sharings.student_id = ? and users.is_blocked = ?", student_id, false).order("users.first_name ASC, users.last_name ASC") + self.where(:student_id => student_id).order("first_name ASC, last_name ASC")).uniq
  end 
  protected

    def save_token 
      self.update_attribute(:confirm_token, Digest::SHA1.hexdigest(self.email))
      user = User.find_by_email(self.email)
      if user
        self.update_attribute(:user_id, user.id)
      end
    end  
end
