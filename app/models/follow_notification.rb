class FollowNotification < Notification
  
end

# == Schema Information
#
# Table name: notifications
#
#  id           :integer(4)      not null, primary key
#  recipient_id :integer(4)      not null
#  target_id    :integer(4)      not null
#  target_type  :string(255)     not null
#  unread       :integer(4)      default(1)
#  type         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

