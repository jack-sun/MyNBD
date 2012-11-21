class Poll < ActiveRecord::Base
  has_many :polls_options, :dependent => :destroy
  belongs_to :owner, :polymorphic => :true
  has_many :polls_logs
  belongs_to :staff

  accepts_nested_attributes_for :polls_options, :allow_destroy => true, :reject_if => lambda{|a| a[:content].blank?}
  VERIFY_TYPE_IP = 0
  VERIFY_TYPE_LOGIN = 1
  VERIFY_TYPE_COOKIE = 2

  NEED_CAPCHA = 1
  NOT_NEED_CAPCHA = 0

  SHOW_RESULT_AFTER_VOTE = 0
  HIDE_RESULT_AFTER_VOTE = 1
  SHOW_RESULT_TO_ALL = 2

  def vote_by_this_ip?(ip)
    PollsLog.where(:poll_id => self.id, :remote_ip => ip).first
  end

  def vote_by_this_user?(user_id)
    PollsLog.where(:poll_id => self.id, :user_id => user_id).first
  end

  def need_capcha?
    self.need_capcha == NEED_CAPCHA
  end

  def expiried?
    Time.now > self.expired_at
  end
end
