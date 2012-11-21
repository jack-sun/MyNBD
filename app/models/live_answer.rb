class LiveAnswer < ActiveRecord::Base
  belongs_to :live_talk, :counter_cache => :answer_count
  belongs_to :weibo

  after_save :touch_live_talk
  def touch_live_talk
    self.live_talk.update_attribute(:updated_at, self.updated_at)
  end
end
