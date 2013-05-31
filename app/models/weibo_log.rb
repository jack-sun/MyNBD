#encoding:utf-8
class WeiboLog < ActiveRecord::Base

  belongs_to :weibo
  belongs_to :staff

  PUBLISH = 0
  DELETE = 1
  BAN = 2

  ACTION = {BAN => "屏蔽", DELETE => "删除", PUBLISH => "发布"}

  class << self
    def add_weibo_log(weibo_id, staff_id, cmd, remote_ip)
      WeiboLog.create(:weibo_id => weibo_id, :staff_id => staff_id, :cmd => cmd, :remote_ip => remote_ip) ? true : false
    end
  end

  def cmd_type
    ACTION[self.cmd]
  end

end
