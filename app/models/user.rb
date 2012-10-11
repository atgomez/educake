class User < ActiveRecord::Base
  ROLES = %w[admin principal teacher parent]

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, 
  :last_name, :phone, :classroom
  
  has_many :children, :class_name => "User"
  belongs_to :parent, :class_name => "User", :foreign_key => 'parent_id'
  
  has_many :students, :foreign_key => "teacher_id", :dependent => :destroy
  has_many :student_sharings, :dependent => :destroy
  has_many :shared_students, :through => :student_sharings, :source => :student
  
  validates_presence_of :first_name, :last_name

  def full_name
    "#{self.first_name} #{self.last_name}"
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

