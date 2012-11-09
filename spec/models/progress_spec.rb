# == Schema Information
#
# Table name: progresses
#
#  id         :integer          not null, primary key
#  goal_id    :integer          not null
#  due_date   :date             not null
#  accuracy   :float            default(0.0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Progress do
  pending "add some examples to (or delete) #{__FILE__}"
end
