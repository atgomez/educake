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
#  goal_x           :integer          default(0), not null
#  goal_y           :integer          default(0), not null
#

require 'spec_helper'

describe Grade do
	let(:curriculum) {
		FactoryGirl.create(:curriculum)
	}
	let(:subject) {
		FactoryGirl.create(:subject, :name => 'SUBJECT ABC')
	}
	let(:user) {FactoryGirl.create(:teacher)}
	let(:student) { FactoryGirl.create(:student, :teacher => user) }

	let(:goal) { 
		FactoryGirl.create(:goal_with_grades, 
											 :curriculum => curriculum, 
											 :student => student)
	}

	let(:grade) { 
		FactoryGirl.build(:grade, :due_date => Date.today, :goal => goal)
	}

  context	'with Instance Methods' do
  	context 'with #due_date_string' do
			it { grade.due_date_string.should == ::Util.date_to_string(grade.due_date)}
		end

		context 'with #due_date=' do
			it { 
				grade.due_date = '11-20-2013'
				grade.due_date.should == ::Util.format_date('11-20-2013')
			}
		end
  end

  context 'with Class Methods' do
  	context 'when #load_data' do
			before {
					@goal = goal
					@grades = []
					(1..30).each do |i|
						new_grade = FactoryGirl.build(:grade, :due_date => Date.today - (i + 4).days, :goal => @goal)
					  if !new_grade.save
					  	puts new_grade.errors.inspect
					  end

					  @grades << new_grade
					end
				}
			context 'when using default variables' do
				it { Grade.load_data.length.should eq(15)	}
			end

			context 'when passing paging params to' do 
				before {
					@paginated_goal = Grade.load_data({:page_id => 3, :page_size => 14})
				}
				it { @paginated_goal.length.should eq(@grades.count - (14*2))	}
			end
		end
  end

  context 'when create or edit' do
  	context 'with valid values ' do
  	end

  	context 'with invalid values' do
  		context 'with number' do
  			let(:invalid_number_range) { 
					grade = FactoryGirl.build(:grade, :due_date => Date.today - 1.days, :goal => goal)
					grade.accuracy = 101
					grade
				}
				it {
					invalid_number_range.save
					invalid_number_range.errors.should have_at_least(1).error_on(:accuracy)
				}
  		end

  		context 'with datetime' do
  			let(:invalid_due_date_1) { 
					FactoryGirl.build(:grade, :due_date => goal.baseline_date - 1.days, :goal => goal)
				}
				let(:invalid_due_date_2) { 
					FactoryGirl.build(:grade, :due_date => goal.due_date + 1.days, :goal => goal)
				}
				let(:invalid_due_date_3) { 
					FactoryGirl.build(:grade, :due_date => Date.today + 1.days, :goal => goal)
				}
				it {
					invalid_due_date_1.save
					invalid_due_date_1.errors.should have_at_least(1).error_on(:due_date)
				}
				it {
					invalid_due_date_2.save
					invalid_due_date_2.errors.should have_at_least(1).error_on(:due_date)
				}
				it {
					invalid_due_date_3.save
					invalid_due_date_3.errors.should have_at_least(1).error_on(:due_date)
				}
  		end
  	end
  end
end
