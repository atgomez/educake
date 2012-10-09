class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, 
  :last_name, :phone, :classroom, :role_id
  
  has_many :children, :class_name => "User"
  belongs_to :parent, :class_name => "User", :foreign_key => 'parent_id'
  
  has_many :students, :foreign_key => "teacher_id"
  
  validates_presence_of :first_name, :last_name
end
