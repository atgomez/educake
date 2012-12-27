# == Schema Information
#
# Table name: goals
#
#  id                :integer          not null, primary key
#  student_id        :integer          not null
#  curriculum_id     :integer          not null
#  accuracy          :float            default(0.0), not null
#  baseline          :float            default(0.0), not null
#  baseline_date     :date             not null
#  due_date          :date             not null
#  trial_days_total  :integer          not null
#  trial_days_actual :integer          not null
#  description       :text
#  is_completed      :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'spec_helper'



describe Goal do

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
		FactoryGirl.build(:goal, 
											 :curriculum => curriculum, 
											 :subject => subject,
											 :student => student)
	}

	let(:progress_1) {
		progress_1 = FactoryGirl.build(:progress, :due_date => Date.parse('01/02/2013'), :accuracy => 45, :goal => goal)
	}

	let(:progress_2) {
		FactoryGirl.build(:progress, :due_date => Date.parse('01/05/2013'), :accuracy => 70, :goal => goal)
	}

	let(:progress_3) {
		FactoryGirl.build(:progress, :due_date => Date.parse('01/08/2013'), :accuracy => 80, :goal => goal)
	}

	context	'with Instance Methods' do 
		before(:each){
				@goal = goal
				@goal.build_progresses
				@goal.progresses[0] = progress_1
				@goal.progresses[1] = progress_2
				@goal.progresses[2] = progress_3
				@goal.save
				progress_1.save
				progress_2.save
				progress_3.save
				

				# Base on data example
				@due_dates = ['02/11/2012', '05/11/2012', '06/11/2012', 
										 '07/11/2012', '08/11/2012', '09/11/2012', 
										 '12/11/2012', '13/11/2012', '14/11/2012',
										 '15/11/2012', '16/11/2012', '19/11/2012']

				@values = [20, 22, 22, 23, 19, 21, 25, 24, 26, 22.78, 23.22, 23.22]
				@accuracies = [20, 22, 22, 23, 19, 21, 25, 24, 26, 22, 24, 22]
				@grades = []
				(0...12).each do |i|
					grade = @goal.build_grade({:due_date => Date.parse(@due_dates[i]), :accuracy => @accuracies[i]}, true)
					grade = @goal.update_grade_state(grade)
					grade.save!
					@grades << grade
				end
			}

		context 'with #name' do
			it {goal.name.should == "SUBJECT ABC CURRICULUM ABC"}
		end

		context 'with #update_grade_state' do
			(0...12).each do |idx|
				
				context "when checking grade ##{idx}" do
					it {
						(@grades[idx].value - @values[idx]).abs.should <= 0.01
					}
				end
			end
			
		end

		context 'with #due_date_string' do
			it { goal.due_date_string.should == ::Util.date_to_string(goal.due_date)}
		end

		context 'with #baseline_date_string' do 
			it { goal.baseline_date_string.should == ::Util.date_to_string(goal.baseline_date)}
		end

		context 'with #due_date=' do
			it { 
				goal.due_date = '11-20-2013'
				goal.due_date.should == ::Util.format_date('11-20-2013')
			}
		end

		context 'with #baseline_date=' do
			it { 
				goal.baseline_date = '11-20-2011'
				goal.baseline_date.should == ::Util.format_date('11-20-2011')
			}
		end

		context 'with #last_grade' do
		end

		context	'with #on_grade_now?' do
			it {@goal.on_grade_now?.should == false}
		end

		context 'with #on_over_trial_days?' do
			it {@goal.on_over_trial_days?.should == true}
		end

		context 'with #on_track?' do
			it {@goal.on_track?.should == false}
		end

		context 'with #graph_ideal_value_for_date' do
			context 'in range date' do
				it {
					ideal_value = @goal.graph_ideal_value_for_date(Date.parse('12/11/2012'))
					(ideal_value - 22.99).abs.should <= 0.01
				}
			end

			context 'out of range date' do 
				it {
					ideal_value = @goal.graph_ideal_value_for_date(Date.parse('12/11/2014'))
					ideal_value.should == @goal.accuracy
				}

				it {
					ideal_value = @goal.graph_ideal_value_for_date(Date.parse('12/11/2010'))
					ideal_value.should == @goal.baseline
				}
			end
		end

		context 'with #build_progresses' do
			it {
				goal.build_progresses
				goal.progresses.length.should == 3
			}
		end

		context 'with #parse_csv' do
		end

		context 'with #goal_grade' do
		end

		context 'with #export_xml' do
		end

		context 'with #series_json' do
		end


	end

	context 'with Class Methods' do
		context 'when #load_data' do
			before {
					@goals = []
					(1..30).each do |i|
						new_goal = FactoryGirl.build( :goal, 
																					:student => student, 
																					:curriculum => curriculum, 
																					:subject => subject,
																					:due_date => Date.today + 1.years + i.days)
					  new_goal.is_completed = (i % 2 == 0)
					  new_goal.save
					  @goals << new_goal
					end
				}
			context 'when using default variables' do
				it { Goal.load_data.length.should eq(30)	}
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

			context 'with validate goal name' do
				before(:each){
					@goal = goal
					@goal.save
					@duplicated_goal = goal.clone
					@duplicated_goal.id = nil
					@duplicated_goal.save
				}
				it{	@duplicated_goal.errors.should have_at_least(1).error_on(:due_date)	}
				it{	@duplicated_goal.errors.should have_at_least(1).error_on(:subject_id)	}
				it{	@duplicated_goal.errors.should have_at_least(1).error_on(:curriculum_id)	}
			end
	 	end
	end

	

end
