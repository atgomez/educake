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
  pending "add some examples to (or delete) #{__FILE__}"
end
