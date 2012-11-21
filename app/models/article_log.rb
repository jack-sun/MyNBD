#encoding:utf-8
class ArticleLog < ActiveRecord::Base
  belongs_to :article
  belongs_to :staff

  UPDATE = 0
  DELETE = 1
  BAN = 2
  PUBLISH = 3

  ACTION = {UPDATE => "更新", DELETE => "删除", BAN => "屏蔽", PUBLISH => "发布"}

  def cmd_type
    ACTION[self.cmd]
  end
end
