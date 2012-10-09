# == Schema Information
#
# Table name: invitations
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  email      :string(255)      not null
#  role_id    :integer
#  student_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Invitation do
  pending "add some examples to (or delete) #{__FILE__}"
end
