require 'spec_helper'

describe StudentSharing do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: student_sharings
#
#  id            :integer          not null, primary key
#  email         :string(255)      not null
#  role_id       :integer
#  student_id    :integer          not null
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  confirm_token :string(255)
#  first_name    :string(255)
#  last_name     :string(255)
#

