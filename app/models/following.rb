class Following < ActiveRecord::Base
  after_create CacheCallback::FollowingCallback
  belongs_to :user
  belongs_to :following, :class_name => "User", :foreign_key => "following_user_id"
end

# == Schema Information
#
# Table name: followings
#
#  id                :integer(4)      not null, primary key
#  user_id           :integer(4)      not null
#  following_user_id :integer(4)      not null
#  created_at        :datetime
#  updated_at        :datetime
#

