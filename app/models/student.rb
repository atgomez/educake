class Student < ActiveRecord::Base
  attr_accessible :birthday, :first_name, :gender, :last_name, :teacher_id, :photo
  belongs_to :teacher, :class_name => "User"
  has_attached_file :photo, :styles => { :small => "200x200>", :medium => "300x300>" }, 
                   :storage => :s3,
                   :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
                   :default_url => 'missing.png',
                   :path => "photos/:id/:style.:extension"
  #validates_attachment_size :photo, :less_than => 5.megabytes
 # validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']

  # ASSOCIATION
  has_many :invitations, :dependent => :destroy

  # VALIDATION
  validates_presence_of :first_name, :last_name
end

# == Schema Information
#
# Table name: students
#
#  id         :integer          not null, primary key
#  first_name :string(255)      not null
#  last_name  :string(255)      not null
#  birthday   :date
#  teacher_id :integer
#  gender     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

