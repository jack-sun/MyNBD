#encoding: utf-8
class LiveTalk < ActiveRecord::Base

  
  TYPE_TALK = 0
  TYPE_QUESTION = 1
  TYPE_EDITOR_QUESTION = 2
  STATUS_BAN = 0
  STATUS_PUBLISHED = 1
  paginates_per Settings.count_per_page

  belongs_to :live
  belongs_to :weibo, :dependent => :destroy
  has_many :live_answers, :order => "id desc"

  before_create :set_question_answer_for_18

  after_save :touch_stock_live
  after_destroy :touch_stock_live

  attr_accessor :question_page

  def touch_stock_live
    if self.talk_type == TYPE_QUESTION
      Live.update_question_timeline(self.live_id, self.updated_at)
    else
      Live.update_timeline(self.live_id, self.updated_at)
    end
  end

  def set_question_answer_for_18
    if Weibo.content_check_needed? and self.is_a_user_question?
      self.status = STATUS_BAN
      self.weibo.status = Weibo::BANNDED
      self.weibo.save!
    end
  end

  scope :comment, where(:talk_type => TYPE_TALK)
  scope :question, where(:talk_type => TYPE_QUESTION)
  scope :published, where(:status => STATUS_PUBLISHED)
  
  #DESC: 是否为主持人或者嘉宾的发言
  def is_a_talk?
    self.talk_type == TYPE_TALK
  end

  def is_a_editors_talk?
    self.talk_type == TYPE_TALK or self.talk_type == TYPE_EDITOR_QUESTION
  end
  
  #DESC: 是否为用户的提问
  def is_a_question?
    self.talk_type == TYPE_QUESTION or self.talk_type == TYPE_EDITOR_QUESTION
  end

  def is_a_user_question?
    self.talk_type == TYPE_QUESTION 
  end

  def is_ban?
    self.status == 0
  end

  def to_ban!
    LiveTalk.transaction do
      self.status = 0
      self.weibo.status = Weibo::BANNDED
      self.weibo.save!
      self.save!
    end
  end

  def to_unban!
    LiveTalk.transaction do
      self.status = 1
      self.weibo.status = Weibo::PUBLISHED
      self.weibo.save!
      self.save!
    end
  end
  
end
