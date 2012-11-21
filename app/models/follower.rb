class Follower < ActiveRecord::Base
  belongs_to :user
  belongs_to :follower, :class_name => "User", :foreign_key => "follower_user_id"
end

# == Schema Information
#
# Table name: followers
#
#  id               :integer(4)      not null, primary key
#  user_id          :integer(4)      not null
#  follower_user_id :integer(4)      not null
#  created_at       :datetime
#  updated_at       :datetime
#

