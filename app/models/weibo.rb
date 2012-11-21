  # encoding: utf-8
require 'nbd/check_spam'
class Weibo < ActiveRecord::Base

  include CacheCallback::HotResult
  include Nbd::CheckSpam

  NEWEST_WEIBO_FRAGMENT_KEY = "newest_weibo_fragment_key"

  check_spam_attr "content"

  paginates_per Settings.count_per_page
  after_create CacheCallback::WeiboCallback
  after_destroy CacheCallback::WeiboCallback
  
  include Redis::Objects

  hash_key :weibo_article_id, :global => true
  value :content_check, :global => true
 
  PUBLISHED = 1
  BANNDED = PENDING = 2
  STATUS = {PUBLISHED => "已发布", BANNDED => "屏蔽/待审核"}
  
  DEFAULT_RT_CONENT = "转发微博"
  
  include MentionTarget
  
  attr_accessor :comment_to_parent, :comment_to_ori
  
  #assoctation
  has_one :live_talk
  has_one :live_answer

  belongs_to :owner, :polymorphic => :true, :counter_cache => "weibos_count"

  has_one :article

  has_many :comments, :conditions => {:status => PUBLISHED}
  has_many :all_comments, :class_name => "Comment", :foreign_key => "ori_weibo_id", :conditions => {:status => PUBLISHED}

  has_many :tags_weibos
  has_many :tags, :through => :tags_weibos

  has_many :rt_weibos, :class_name => "Weibo", :foreign_key => "ori_weibo_id"
  belongs_to :ori_weibo, :class_name => "Weibo", :foreign_key => "ori_weibo_id", :counter_cache => "rt_count"
  default_scope order 'id DESC'

  has_many :children_weibos, :class_name => "Weibo", :foreign_key => "parent_weibo_id"
  belongs_to :parent_weibo, :class_name => "Weibo", :foreign_key => "parent_weibo_id"

  has_many :polls, :as => :owner, :dependent => :destroy
  
  scope :banned, where(:status => BANNDED)
  scope :published, where(:status => PUBLISHED)
  
  # 系统帐号所发的微薄
  scope :sys, where(["owner_id in (?) AND owner_type = ?", User::SYSTEM_USER_IDS, User.to_s])
  # 普通用户帐号所发的微薄（排除了系统帐号哦所发的微薄）
  scope :exclude_sys, where(["owner_id not in (?) AND owner_type = ?", User::SYSTEM_USER_IDS, User.to_s])
  
  define_index do
    # fields
    indexes content

    # attributes
    has :id, status, created_at, updated_at
    
    # 声明使用实时索引
    set_property :delta => true
  end
  
  before_destroy :decrease_parent_weibo_rt_count

  after_create :notify_online_user
  def notify_online_user
    follower_ids = User.get_cache_followers_list(self.owner_id).values
    online_user_ids = User.online_users.keys
    notify_user_ids = (follower_ids & online_user_ids).map(&:to_i)
    #notify_user_ids << self.owner_id
    puts "###################"
    puts notify_user_ids,online_user_ids,follower_ids
    puts "###################"
    notify_user_ids.each do |user_id|
      next if user_id == self.owner_id
      User.get_new_weibo_ids_list(user_id) << self.id
      puts User.get_new_weibo_ids_list(user_id)
    end
  end
  
  def is_banned?
    self.status == BANNDED
  end
  
  class << self

    def set_content_check_status(status)
      Weibo.content_check.value = status.to_s
    end
    
    def content_check_needed?
      return false if Weibo.content_check.blank?
      Weibo.content_check.value == "1"
    end
    
    def hot_rt_weibos(limit = 10, asso_hash = {})
      hot_objects("hot_cache:result:hot_rt_weibo", limit, asso_hash)
    end
    
    def hot_comment_weibos
      where(:status => PUBLISHED).order("id DESC")
    end
    
    def newest_weibos(limit, filter_user_ids=User::SYSTEM_USER_IDS)
      query = where(:status => PUBLISHED).order("id DESC").limit(limit)
      query = query.where(["owner_id not in (?) AND owner_type = ?", filter_user_ids, User.to_s]) if filter_user_ids.present?
      query
    end
  
    def format(content)
      {:content => content}
    end
  
    def ban_weibo(weibo_id)
      weibo = self.where(:id => weibo_id).first
      return if weibo.blank?
      
      weibo.status = BANNDED
      weibo.delta = true
      weibo.save
      
      #self.update_all(["status = ?,", BANNDED], ["id = ?", weibo_id])
    end
    
    def unban_weibo(weibo_id)
      weibo = self.where(:id => weibo_id).first
      return if weibo.blank?
      
      weibo.status = PUBLISHED
      weibo.delta = true
      weibo.save
      
      #self.update_all(["status = ?", PUBLISHED], ["id = ?", weibo_id])
    end
    
    #_DESC_: 
    # 1. build logical content: truncate extra characters(300 characters max) with meaningful patterns 
    # 2. detect if content contain hash tags
    # 3. detect if current weibo is a original one 
    #_IN_:
    # weibo_params: {weibo_fields,...}
    #_OUT_:
    # {:weibo_params => weibo_params, :tags => []}
    def preprocess_weibo_params(weibo_params)
      weibo_params[:content] = truncate_meaningful_content(weibo_params[:content])
      hash_tags = extract_hash_tags(weibo_params[:content])
      weibo_params[:has_tag] = 1 unless hash_tags.blank?
      weibo_params[:weibo_type] = 1 if weibo_params[:orgin_weibo_id] != 0
      {:weibo_params => weibo_params, :tags => hash_tags}
    end
    
    #TODO
    def truncate_meaningful_content(content)
      content
    end
    
    #TODO
    def extract_hash_tags(content)
      []
    end
  end

  def self.comment_articles(weibo_ids)
    return {} if weibo_ids.blank?
    id_hash = Weibo.weibo_article_id.bulk_get(*weibo_ids)   
    article_ids = id_hash.values
    article_hash = Article.where(:id => article_ids).to_a.group_by{|x| x.weibo_id}
  end
 
  def add_tags(tags)
    tags.each do |tag|
      Tag.calculate_daily_count(tag)
      self.tags << tag
    end
  end

  def is_ori_weibo?
    self.ori_weibo_id == 0
  end

  def ori_article_id
    self.is_ori_weibo? ? nil : Weibo.weibo_article_id[self.ori_weibo_id]
  end

  def ori_weibo_id_or_self_id
    self.is_ori_weibo? ? self.id : self.ori_weibo_id
  end

  #def ori_weibo
    #self.is_ori_weibo? ? self : super
  #end
  
  private
  
  # A <-- B <-- C: 
  # if weibo C been deleted, weibo A's rt_count will be decreased automatically according to counter_cache config.
  # however,  weibo B(the parent weibo of weibo C)'s rt_count will not. We need decrease the rt_count manually
  def decrease_parent_weibo_rt_count
    return if self.parent_weibo.blank? or self.parent_weibo_id == 0
    Weibo.decrement_counter("rt_count", self.parent_weibo.id) if self.parent_weibo.ori_weibo_id != 0
  end

end


# == Schema Information
#
# Table name: weibos
#
#  id              :integer(4)      not null, primary key
#  owner_id        :integer(4)      not null
#  owner_type      :string(255)     not null
#  has_tag         :integer(4)      default(0)
#  content         :text            default(""), not null
#  parent_weibo_id :integer(4)      default(0), not null
#  ori_weibo_id    :integer(4)      default(0), not null
#  rt_count        :integer(4)      default(0)
#  reply_count     :integer(4)      default(0)
#  article_id      :integer(4)      default(0)
#  weibo_type      :integer(4)      default(0)
#  content_type    :integer(4)      default(0)
#  created_at      :datetime
#  updated_at      :datetime
#


# == Schema Information
#
# Table name: weibos
#
#  id              :integer(4)      not null, primary key
#  owner_id        :integer(4)      not null
#  owner_type      :string(255)     not null
#  has_tag         :integer(4)      default(0)
#  content         :text            default(""), not null
#  parent_weibo_id :integer(4)      default(0), not null
#  ori_weibo_id    :integer(4)      default(0), not null
#  rt_count        :integer(4)      default(0)
#  reply_count     :integer(4)      default(0)
#  article_id      :integer(4)      default(0)
#  weibo_type      :integer(4)      default(0)
#  content_type    :integer(4)      default(0)
#  created_at      :datetime
#  updated_at      :datetime
#

