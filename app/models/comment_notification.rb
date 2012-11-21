class CommentNotification < Notification
  before_create :update_user_cache_counter
  
  def update_user_cache_counter
    counter= User.get_cache_notifications_hash_key(self.recipient_id)
    counter.incrby(:new_comments_count)
  end
  
  
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

