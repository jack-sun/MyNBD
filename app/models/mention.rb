class Mention < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, :polymorphic => true
  
  scope :weibos, where(:target_type => Weibo.to_s)
  scope :comments, where(:target_type => Comment.to_s)


  after_create :notify_user
  def notify_user
    notify_hash = User.get_cache_notifications_hash_key(self.user_id)
    if self.target_type == "Weibo"
      notify_hash.incrby("new_atme_weibos_count")
    elsif self.target_type == "Comment"
      notify_hash.incrby("new_atme_comments_count")
    end
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

