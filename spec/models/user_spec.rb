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

require 'spec_helper'

describe User do
#  describe "attributes" do
#    it { should have_attribute(:email) }
#    #it { should have_attribute(:password) }
#    #it { should have_attribute(:password_confirmation) }
#    #it { should have_attribute(:remember_me) }
#    it { should have_attribute(:first_name) }
#    it { should have_attribute(:last_name) }
#    it { should have_attribute(:classroom) }
#    it { should have_attribute(:confirmed_at) }
#    it { should have_attribute(:parent_id) }
#    it { should have_attribute(:role_id) }
#    it { should have_attribute(:school_id) }
#  end

#  describe 'associations' do
#    it { should have_many(:children).class_name("User")}#.foreign_key('patient_id')
#    it { should have_one(:student_sharing).dependent(:destroy)}
#    it { should have_many(:student_sharings).dependent(:destroy)}
#    it { should have_many(:shared_students).through(:student_sharings)}#.source(:student)
#    it { should have_many(:students).dependent(:destroy)}#.foreign_key("teacher_id")
#    it { should belong_to(:role) }
#    it { should belong_to(:school) }
#  end
  
  describe 'validates' do
    it { should validate_presence_of(:first_name)}
    it { should validate_presence_of(:last_name)}
    it { should validate_presence_of(:email)}
    it { should validate_presence_of(:role)}#, :unless => :is_super_admin?)}
    it { should validate_presence_of(:school_id)}#, :if => :is_not_admin?)}
    it {should ensure_length_of(:first_name).is_at_most(15)}
    it {should ensure_length_of(:last_name).is_at_most(15)}
  end 
end
