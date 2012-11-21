class CommentLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment
  before_create :update_user_cache_counter
  
  def update_user_cache_counter
    counter= User.get_cache_notifications_hash_key(self.user_id)
    counter.incrby(:new_comments_count)
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

