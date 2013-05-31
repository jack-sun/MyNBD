#encoding:utf-8
class CommunitySwitchLog < ActiveRecord::Base

  belongs_to :staff

  ON = 1
  OFF = 0

  ACTION = {ON => "打开", OFF => "关闭"}

  class << self
    def add_community_switch_logs(staff_id, cmd, remote_ip, roll_back_status)
      Weibo.content_check.value = roll_back_status unless CommunitySwitchLog.create(:staff_id => staff_id, :cmd => cmd, :remote_ip => remote_ip)
    end
  end

  def cmd_type
    ACTION[self.cmd]
  end

end
