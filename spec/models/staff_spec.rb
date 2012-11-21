require 'spec_helper'

describe Staff do
  pending "add some examples to (or delete) #{__FILE__}"
end


# == Schema Information
#
# Table name: staffs
#
#  id              :integer(4)      not null, primary key
#  name            :string(64)      not null
#  real_name       :string(64)      not null
#  hashed_password :string(32)      not null
#  salt            :string(32)
#  email           :string(64)
#  phone           :string(32)
#  user_type       :integer(4)      default(0)
#  comment         :string(500)
#  status          :integer(4)      default(1), not null
#  creator_id      :integer(4)      default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#

