# == Schema Information
#
# Table name: grades
#
#  id               :integer          not null, primary key
#  goal_id          :integer          not null
#  user_id          :integer
#  progress_id      :integer
#  due_date         :date             not null
#  accuracy         :float            default(0.0), not null
#  value            :float            default(0.0)
#  ideal_value      :float            default(0.0)
#  time_to_complete :time
#  is_unused        :boolean          default(FALSE)
#  note             :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'spec_helper'

describe Grade do
  let(:curriculum) {
    curriculum = FactoryGirl.create(:curriculum)
    curriculum.name = 'CURRICULUM ABC'
    curriculum.save
    curriculum
  }

  let(:subject) {
    subject = FactoryGirl.create(:subject)
    subject.name = 'SUBJECT ABC'
    subject.save
    subject
  }
  
  let(:user) {FactoryGirl.create(:teacher)}
  let(:student) { FactoryGirl.create(:student, :teacher => user) }

  let(:goal) { 
    FactoryGirl.create(:goal_with_grades, 
                       :curriculum => curriculum, 
                       :subject => subject,
                       :student => student)
  }

  context	'with Instance Methods' do
  end

  context 'with Class Methods' do
  end

  context 'when create or edit' do
  	context 'with valid values ' do
  	end

  	context 'with invalid values' do
  		context 'with number' do
  		end

  		context 'with datetime' do
  		end
  	end
  end
end
