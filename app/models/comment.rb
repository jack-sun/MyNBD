# encoding: utf-8
require 'nbd/check_spam'
class Comment < ActiveRecord::Base

  after_create CacheCallback::CommentCallback
  after_destroy CacheCallback::CommentCallback
  paginates_per Settings.count_per_page

  include Nbd::CheckSpam

  check_spam_attr "content"

  scope :article_comments, where("article_id is not null")
  
  include MentionTarget
  
  PUBLISHED = 1
  BANNDED = PENDING = 2
  STATUS = {PUBLISHED => "已发布", BANNDED => "屏蔽/待审核"}
  
  attr_accessor :rt_weibo, :comment_to_ori_weibo
  
  #assoctation
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id" 
  belongs_to :weibo, :counter_cache => "reply_count"
  belongs_to :ori_weibo, :class_name => "Weibo", :foreign_key => "ori_weibo_id"

  belongs_to :parent, :class_name => "Comment", :foreign_key => "parent_comment_id"

  has_many :comment_logs, :dependent => :destroy
  belongs_to :article
  
  scope :published, where(:status => PUBLISHED)

  before_create :add_ori_weibo_id
  def add_ori_weibo_id
    self.ori_weibo_id = self.weibo_id if self.ori_weibo_id.blank?
  end
  
  class << self
    
    def content_check_needed?
      Weibo.content_check_needed?
    end
    
    def ban_comment(comment_id)
      self.update_all(["status = ?", BANNDED], ["id = ?", comment_id])
    end
  end
end

# == Schema Information
#
# Table name: comments
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      not null
#  weibo_id     :integer(4)      not null
#  ori_weibo_id :integer(4)      not null
#  content      :text            default(""), not null
#  created_at   :datetime
#  updated_at   :datetime
#

