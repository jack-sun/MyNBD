require 'spec_helper'

describe CommentLog do
  it "test dependent destroy" do
    user = Factory.create(:user1)
    comment = Factory.create(:comment)
    c = CommentLog.create(:user => user, :comment => comment)
    comment.destroy
    user.comment_logs.should be_blank
  end
end

# == Schema Information
#
# Table name: comment_logs
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  comment_id :integer(4)      not null
#  created_at :datetime
#  updated_at :datetime
#

