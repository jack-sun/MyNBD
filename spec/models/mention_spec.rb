require File.expand_path('spec/spec_helper')

describe Mention do
  it "test depend dstroy" do
    user = Factory.create(:user)
    user1 = Factory.create(:user1)
    weibo = user1.create_weibo(:content => "@jason haha")
    user.mentions.first.target.should == weibo
    weibo.destroy
    user.reload
    user.mentions.should be_blank
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

