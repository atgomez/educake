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
  
  has_many :students, :foreign_key => "teacher_id"
  
  validates_presence_of :first_name, :last_name

  def full_name
    "#{self.first_name} #{self.last_name}"
  end
end
