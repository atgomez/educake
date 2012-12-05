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
  pending "add some examples to (or delete) #{__FILE__}"
end
