class StudentSharing < ActiveRecord::Base
  attr_accessible :email, :first_name, :last_name, :student_id, :user_id, :role_id, :confirm_token

  # ASSOCIATION
  belongs_to :student
  belongs_to :user
  belongs_to :role
  
  # VALIDATION
  validates :first_name, :last_name, :email, :student_id, :role_id, :presence => true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  validates :email, :uniqueness => { :scope => [:student_id]}
  after_create :save_token
  def save_token 
    self.update_attribute(:confirm_token, Digest::SHA1.hexdigest(self.email))
    user = User.find_by_email(self.email)
    if user
      self.update_attribute(:user_id, user.id)
    end
  end
  
  def full_name
    [self.first_name, self.last_name].join(" ")
  end  
end

# == Schema Information
#
# Table name: student_sharings
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  email      :string(255)      not null
#  role_id    :integer
#  student_id :integer          not null
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

