#encoding:utf-8
class Live < ActiveRecord::Base
  set_table_name :stock_lives
  include Redis::Objects

  has_many :live_guests, :dependent => :destroy
  has_many :guests, :through => :live_guests

  hash_key :live_timeline, :global => true
  hash_key :live_question_timeline, :global => true
  hash_key :live_start_end_time, :global => true
  has_many :live_talks, :dependent => :destroy
  belongs_to :user
  belongs_to :image

  ORDER_BY_CREATED_AT = 1
  ORDER_BY_UPDATED_AT = 0

  PUBLISHED = 1
  DRAFT = 0
  BANNDED = 2
  STATUS = {PUBLISHED => "已发布", DRAFT => "屏蔽/"}

  LIVE_SHOW_TYPE_KEY = "live_show_type_key"

  SHOW_ANSWER_IN_MOBILE = false
  
  scope :published, where(:status => PUBLISHED)

  COMMUNITY_INDEX_FRAGMENT_KEY = "community_index_stock_live_fragment_key"
  COMMUNITY_INDEX_QA_FRAGMENT_KEY = "community_index_stock_live_qa_fragment_key"
  HOME_INDEX_FRAGMENT_KEY = "home_index_stock_live_fragment_key"

  DEFAULT_NAME_PREFIX = "股市直播"

  UPDATE_STOCK_LIVE_KEY = "udpate_stock_live_key"
  START_AND_END_TIME_KEY = "stock_live_start_end_time"

  TYPE_STOCK = 1
  TYPE_ORIGIN = 2

  STATUS_PENDING = 0
  STATUS_GOING = 1
  STATUS_OVER = 2

  scope :stock_lives, where(:l_type => TYPE_STOCK)
  scope :origin_lives, where(:l_type => TYPE_ORIGIN)
  scope :showed_lives, lambda{|x| where(:l_type => x)}

  #
  #callback methods

  before_create :create_s_index
  def create_s_index
    self.s_index = Date.today.strftime("%Y-%m-%d")
  end

  after_save :change_check
  def change_check
    if (self.end_at > Time.now and self.start_at < Time.now) and self.status == 1
      Live.change_cache_status(self.id, 1)
    else
      Live.change_cache_status(self.id, 0)
    end
    Live.add_start_and_end_time_cache(self)
  end
  
  #
  #class methods

  class << self

    def update_timeline(live_id, talk_update_at, continue = 1)
      Live.live_timeline[live_id] = [talk_update_at.to_i, continue].join("-")
    end

    def update_question_timeline(live_id, talk_update_at, continue = 1)
      Live.live_question_timeline[live_id] = [talk_update_at.to_i, continue].join("-")
    end

    def get_timeline(live_id, type = LiveTalk::TYPE_TALK)
      result = nil
      if type == LiveTalk::TYPE_TALK
        result = (time_line = Live.live_timeline[live_id]).nil? ? nil : time_line.split("-")
      else
        result = (time_line = Live.live_question_timeline[live_id]).nil? ? nil : time_line.split("-")
      end
      return result
    end

    def check_expire(live_id)
      times = Live.live_start_end_time[live_id]
      if times.blank?
        if (s = Live.where(:id => live_id).first) && !s.try(:is_over?)
          Live.add_start_and_end_time_cache(s)
          return false
        else
          return true
        end
      end
      start_at, end_at = times.split("-").map(&:to_i)
      if start_at > Time.now.to_i or end_at < Time.now.to_i
        Live.change_cache_status(live_id ,0)
        return true
      else
        Live.change_cache_status(live_id, 1)
      end
      return false
    end

    def add_start_and_end_time_cache(live)
      Live.live_start_end_time[live.id] = [live.start_at.to_i, live.end_at.to_i].join("-")
    end

    def change_cache_status(live_id, status = 0)
      time, continue = self.get_timeline(live_id)
      time = Time.now.to_i if time.blank?
      Live.live_timeline[live_id] = [time, status].join("-")
      time, continue = self.get_timeline(live_id, LiveTalk::TYPE_QUESTION)
      time = Time.now.to_i if time.blank?
      Live.live_question_timeline[live_id] = [time, status].join("-")
    end

    def expire_live_cache(live_id)
      Live.live_timeline.delete(live_id)  
      Live.live_question_timeline.delete(live_id)
      Live.live_start_end_time.delete(live_id)
    end

  end

  #直播尚未开始
  def is_pending?
    Time.now < self.start_at
  end

  #直播正在进行重
  def is_going?
    Time.now >= self.start_at and Time.now <= self.end_at 
  end

  #直播已经结束
  def is_over?
    Time.now < self.start_at or Time.now > self.end_at 
  end  

  def live_status
    if self.is_going?
      return STATUS_GOING
    elsif self.is_over?
      return STATUS_OVER
    elsif self.is_pending?
      return STATUS_PENDING
    end
  end

  def is_stock_lives?
    self.l_type == TYPE_STOCK
  end
  
  def is_orign_lives?
    self.l_type == TYPE_ORIGIN
  end

  def all_guest_ids
    @all_guest_ds ||= self.guest_ids
  end

  def important_user
    self.guests + [self.user]
  end

  def self.change_live_show_type(type)
    Rails.cache.write(LIVE_SHOW_TYPE_KEY, type)
  end

  def is_order_by_updated_at?
    self.order_by_type == ORDER_BY_UPDATED_AT
  end

  def is_order_by_created_at?
    self.order_by_type == ORDER_BY_CREATED_AT
  end

end
