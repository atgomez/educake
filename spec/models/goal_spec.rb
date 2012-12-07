# == Schema Information
#
# Table name: goals
#
#  id                       :integer          not null, primary key
#  student_id               :integer          not null
#  subject_id               :integer          not null
#  curriculum_id            :integer          not null
#  accuracy                 :float            default(0.0), not null
#  baseline                 :float            default(0.0), not null
#  baseline_date            :date             not null
#  due_date                 :date             not null
#  trial_days_total         :integer          not null
#  trial_days_actual        :integer          not null
#  grades_data_file_name    :string(255)
#  grades_data_content_type :string(255)
#  grades_data_file_size    :integer
#  grades_data_updated_at   :datetime
#  description              :text
#  is_completed             :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require 'spec_helper'



describe Goal do

	let(:curriculum) {FactoryGirl.create(:curriculum)}
	let(:subject) {FactoryGirl.create(:subject)}
	let(:user) {FactoryGirl.create(:teacher)}
	let(:student) { 
	  student = FactoryGirl.build(:student)
	  student.teacher = user
	  student.save!
	  student
	}

	let(:goal) {
	  goal = FactoryGirl.build(:goal)
	  goal.student = student
	  goal.curriculum = curriculum
	  goal.subject = subject
	  goal.save!
	  goal
	}

	context	'with Instance Methods' do 
		let(:grade) {
			grade = FactoryGirl.build(:grade)
			grade.goal = goal
			grade.user = user
			grade.save!
			grade
		}

		context 'with #update_grade_state' do
		end
	end

	context 'with Class Methods' do
		context 'when #load_data' do
			before {
					@goals = []
					(1..30).each do |i|
						new_goal = FactoryGirl.build(:goal)
					  new_goal.student = student
					  new_goal.curriculum = curriculum
					  new_goal.subject = subject
					  new_goal.is_completed = (i % 2 == 0)
					  new_goal.save
					  @goals << new_goal
					end
				}
			context 'when using default variables' do
				it { Goal.load_data.length.should eq(@goals.count)	}
			end

			context 'when passing paging params to' do 
				before {
					@paginated_goal = Goal.load_data({:page_id => 3, :page_size => 14})
				}
				it { @paginated_goal.length.should eq(@goals.count - (14*2))	}
			end

			context 'when passing complete value' do
				before {
					@paginated_goal = Goal.load_data({}, true)
				}
				it { @paginated_goal.length.should eq(@goals.count/2) } 
			end
		end

		context 'when #build_goal' do
			before{
				@new_goal = Goal.build_goal :trial_days_total => 10, :trial_days_actual => 9, :baseline_date => Date.today
			}
			it { @new_goal.progresses.length.should == 3	}
		end
	end

	context 'when create or edit' do

	 	context 'with valid values ' do
	 		it { goal.should be_valid }
	 	end

	 	context 'with invalid values' do

			context 'with presence invalidation' do

				let(:goal) { 
					goal = Goal.new 
					goal.accuracy = nil
					goal.baseline = nil
					goal
				}

				[:curriculum_id, :subject_id, :baseline, :baseline_date, :due_date, :accuracy, :trial_days_total, :trial_days_actual ].each do |attr|
					it {goal.should have_at_least(1).error_on(attr)}
				end
			end

			context 'with number maximun invalidation' do
				let(:maximun_valid) { 
					new_goal = goal
					new_goal.accuracy = 120
					new_goal.baseline = 101
					new_goal
				}

				[:baseline, :accuracy ].each do |attr|
					it {maximun_valid.should have_at_least(1).error_on(attr)}
				end
			end

			context 'with number minimun invalidation' do
				let(:mimimun_valid) { 
					new_goal = goal
					new_goal.accuracy = -10
					new_goal.baseline = -20
					new_goal
				}

				[:baseline, :accuracy ].each do |attr|
					it {mimimun_valid.should have_at_least(1).error_on(attr)}
				end
			end

			context 'with checking baseline number' do
				let(:invalid_baseline) { 
					new_goal = goal
					new_goal.accuracy = 20
					new_goal.baseline = 70
					new_goal
				}

				it {
					invalid_baseline.save
					invalid_baseline.errors.should have_at_least(1).error_on(:baseline)
				}
			end

			context 'with checking baseline date' do
				let(:invalid_baseline_date) { 
					new_goal = goal
					new_goal.due_date = Time.now
					new_goal.baseline_date = Time.now + 1.days
					new_goal
				}

				it {
					invalid_baseline_date.save
					invalid_baseline_date.errors.should have_at_least(1).error_on(:baseline_date)
				}
			end

			context 'with checking trial days' do
				let(:invalid_trial_days) { 
					new_goal = goal
					new_goal.trial_days_actual = 10
					new_goal.trial_days_total = 9
					new_goal
				}

				it {
					invalid_trial_days.save
					invalid_trial_days.errors.should have_at_least(1).error_on(:trial_days_actual)
				}
			end
	 	end
	end

	

end
