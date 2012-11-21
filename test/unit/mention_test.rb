require 'test_helper'

class MentionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: mentions
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)      not null
#  target_id   :integer(4)      not null
#  target_type :string(255)     not null
#  created_at  :datetime
#  updated_at  :datetime
#

