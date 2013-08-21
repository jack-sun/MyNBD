# encoding: utf-8
require 'nbd/utils'
require 'concerns/encrypt_password'

class User < ActiveRecord::Base
  
  include EncryptPassword, CacheCallback::HotResult

  #User.create(:nickname => "每经网专题", :password => "nbdnbd", :email => "zhuangti@nbd.com.cn", :status => 1, :user_type => 0)
  SYS_USERS = {:feature_user_id => 10348, :live_user_id => 10347}
  SYSTEM_USER_IDS = [10332, 10333, 10334, 10335, 10336, 10337, 10338, 10339, 10347, 10348, 10349, 13033, 13034, 13309, 203165]
  
  USER_TYPE_SYS = 0 # 每经系统用户，如各栏目用户
  USER_TYPE_NORMAL = 0 # 每经用户
  USER_TYPE_ORG = 2 # 机构用户
  USER_TYPE_SUPPER = 3 # 每经超级用户，拥有屏蔽权限

  EXPIRE_ACCESS_TOKEN_TIME = 10

  USER_FANS_SHOW_COUNT = 12
  
  include Redis::Objects
  list :cache_followers, :marshal => true
  list :cache_followings, :marshal => true
  list :new_weibo_ids, :marshal => true
  hash_key :cache_user_info
  hash_key :cache_notifications, :marshal_keys => {:new_atme_weibos_count => true, :new_atme_comments_count => true, :new_comments_count => true, :new_followers_count => true}
  hash_key :user_email_map, :global => true
  hash_key :user_nickname_map, :global => true
  hash_key :online_users, :global => true

  value :cache_access_token
  value :cache_token_updated_at
  
  STATUS_NORMAL = 0
  STATUS_ACTIVE = 1 # email acvivated
  STATUS_BAN = 2
  
  set_table_name "users"
  
  validates_presence_of :email, :nickname, :message => "输入不能为空"
  
  validates_presence_of :password, :on => :create, :message => "输入不能为空"
  
  validates_length_of :password, :minimum => 6, :maxium => 20,
    :too_long => "您输入的密码太长，得少于20个字母加数字或字符的组合", :too_short  => "您输入的密码太短，至少得有6个字母加数字或字符的组合",
    :unless => Proc.new{|u| u.password.blank?}
  
  validates_uniqueness_of :email, :message => '邮箱已经被占用'
  validates_uniqueness_of :nickname, :message => '昵称已经被占用'
  
  
  validates_format_of :email, :with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i,
    :message => '邮箱格式不正确', :if => Proc.new{|u| !u.email.blank?}

  
  validates_length_of :nickname, :within => 4..20, :too_long => "您输入的用户名太长，得少于20个字母或者汉字", 
    :too_short => "您输入的用户名太短，至少得有4个字母或者汉字", :unless => Proc.new{|u| u.nickname.blank?}, :tokenizer => lambda {|str| Array.new(str.bytesize) }
  
  validates_format_of :nickname, :with => /\A[a-z0-9A-Z\u4e00-\u9fa5\-_]+\z/, :message => "用户名格式不正确，需要4到20个汉字、英文或者中划线与下划线"
  
  validates_confirmation_of :password, 
    :message => '两次密码输入不匹配', :if => Proc.new{|u| !u.password.blank?}
  
  attr_accessor :password_confirmation
  attr_reader   :old_password
  
  before_create { generate_token(:auth_token) } 
  
  after_create :init_cache_data
  
  def init_cache_data
    
    self.cache_user_info.clear
    self.cache_user_info[:user_id] = self.id
    self.cache_user_info[:nickname] = self.nickname
    self.cache_user_info[:email] = self.email
    self.cache_user_info[:status] = self.status
    self.cache_user_info[:created_at] = self.created_at.to_i
    self.cache_user_info[:updated_at] = self.updated_at.to_i
    
    self.new_weibo_ids.del
    
    self.cache_followers.del
    self.followers.select("users.id").each do |f|
      self.cache_followers << f.id
    end
    
    self.cache_followings.del
    self.followings.select("users.id").each do |f|
      self.cache_followings << f.id
    end
    
    self.refresh_notifications
    
    User.user_nickname_map[self.nickname] = self.id
    User.user_email_map[self.email] = self.id
  end
  
  def refresh_notifications(target = "all")
    if target == "all"
      self.cache_notifications[:new_atme_weibos_count] = 0
      self.cache_notifications[:new_atme_comments_count] = 0
      self.cache_notifications[:new_comments_count] = 0
      self.cache_notifications[:new_followers_count] = 0
      self.new_weibo_ids.clear
    elsif target == "new_weibo_ids"
      self.new_weibo_ids.clear
    else
      self.cache_notifications[target.to_sym] = 0
    end
  end
  
  def real_time_notifications
    h = {}
    
    self.cache_notifications.all.merge({"new_weibos_count" => self.new_weibo_ids.length, "user_id" => self.id, "nickname" => self.nickname }).each do |k, v|
      case k
        when 'nickname'
        h[k] = v
      else
        h[k] = v.to_i
      end
    end
    
    h
  end
  
  def new_unread_weibo
    Weibo.where(:id => self.new_weibo_ids.values)
  end
  
  #assoctation
  has_many :following_users, :class_name => "Following"
  has_many :followings, :through => :following_users, :source => :following
  
  has_many :follower_users, :class_name => "Follower"
  has_many :followers, :through => :follower_users, :source => :follower
  
  has_many :portfolios
  has_many :stocks, :through => :portfolios
  
  has_many :weibos, :as => :owner, :dependent => :destroy
  has_many :comments
  
  has_many :follow_notifications, :foreign_key => "recipient_id"
  has_many :atme_notifications, :foreign_key => "recipient_id"
  has_many :comment_notifications, :foreign_key => "recipient_id"
  has_many :comment_logs
  
  has_many :refer_comments, :through => :comment_logs, :source => :comment
  
  has_many :mentions
  
  has_many :authentications, :dependent => :destroy

  has_many :live_guests, :dependent => :destroy
  has_many :lives, :through => :live_guests

  has_many :polls_logs

  has_one :mn_account

  has_one :gms_account

  has_many :payments
  
  belongs_to :image, :dependent => :destroy

  has_many :gms_accounts_articles, :class_name => "GmsAccountsArticle"
  has_many :gms_articles, :through => :gms_accounts_articles, :source => :gms_article

  accepts_nested_attributes_for :image , :reject_if => lambda { |a| a[:avatar].blank? && a[:remote_avatar_url].blank?}
  
  define_index do
    # fields
    indexes nickname
    
    # attributes
    has :id, status, created_at, updated_at
    
    # 声明使用实时索引    
    set_property :delta => true
  end
  
  def to_param
    self.nickname
  end
  
  def pay_one_year_for_touzibao?
    return false if self.mn_account.blank?
    return false if self.mn_account.service_end_at.blank?
    return false if self.mn_account.service_end_at < Time.parse("2013-10-20")

    return true
  end

  def paid_one_year_for_ttyj?
    return false if self.mn_account.blank?

    self.mn_account.paid_for?(MnAccount::PLAN_TYPE_YEAR)
  end

  def is_receive_credits_from_ttyj?
    return false if self.mn_account.blank?

    self.mn_account.is_receive_credits?
  end

  def receive_credits_from_ttyj
    User.transaction do
      self.update_attribute(:credits, self.credits + MnAccount::RECEIVE_CREDITS)
      self.gms_account.credit_logs.create({:user_id => self.id,:cmd => CreditLog::CMD_RECEIVE,:credits => MnAccount::RECEIVE_CREDITS, :product_type => CreditLog::PRODUCT_TYPE_MN, :product_id => self.mn_account.id})
      self.mn_account.update_attribute(:is_receive_credits, 1)
    end
  end

  def weibos_following
    Weibo.where("(owner_id in (?) AND owner_type = ? AND status = ?) OR (owner_id = ? AND owner_type = ?)", self.following_ids, self.class.to_s, Weibo::PUBLISHED, self.id, self.class.to_s).includes([{:owner => :image}, {:ori_weibo => {:owner => :image}}]).order("id DESC")
  end
  
  def atme_weibos
    self.mentions.weibos.includes(:target => :owner).order("created_at DESC")
    self.refresh_notifications("new_atme_weibos_count")
  end
  
  def atme_comments
    @targets = @current_user.mentions.comments.includes(:target => :weibo).order("created_at DESC").map(&:target)
    @current_user.refresh_notifications("new_atme_weibos_count")
  end
  
  #def unread_follow_users
  #self.follow_notifications.unread.includes(:target).map(&:target)
  #end
  
  #def unread_atme_weibo_or_comment
  #self.atme_notifications.unread.includes(:target).map(&:target)
  #end
  
  #def unread_comment_to_my_weibo
  #self.comment_notifications.unread.includes(:target).map(&:target)
  #end
  
  #def mark_notification_as_read(type)
  #self.send("#{type}_notifications").unread.update_all(:unread => 0)
  #end
  
  def follow(user)
    User.transaction do
      self.followings << user
      self.cache_followings << user.id
      self.increment!("followings_count")
      user.be_followed(self)
    end
  end
  
  def be_followed(user)
    self.followers << user
    self.cache_followers << user.id
    self.increment!("followers_count")
    self.cache_notifications.incrby(:new_followers_count)
    FollowNotification.create(:recipient => self, :target => user)
  end
  
  def unfollow(user)
    User.transaction do 
      self.followings.delete(user)
      self.cache_followings.delete(user.id)
      self.decrement!("followings_count")
      user.be_unfollowed(self)
    end
  end
  
  def be_unfollowed(user)
    self.followers.delete(user)
    self.cache_followers.delete(user.id)
    self.decrement!("followers_count")
  end
  
  def follow_stock(stock)
    User.transaction do
      self.stocks << stock
      self.increment!("stocks_count")
      stock.increment!("followers_count")
    end
  end
  
  def unfollow_stock(stock)
    User.transaction do 
      self.stocks.delete(stock)
      self.decrement!("stocks_count")
      stock.decrement!("followers_count")
    end
  end
  
  # for stock_live
  def create_stock_live
    
  end
  
  def create_live_talk(live_talk_hash)
    weibo_hash = live_talk_hash.delete("weibo")
    LiveTalk.transaction do
      weibo = self.create_plain_text_weibo(weibo_hash["content"])
      Rails.logger.debug "------------- -----  #{weibo.errors.inspect}"
      live_talk = LiveTalk.create(live_talk_hash.merge!({:weibo_id => weibo.id}))    
      return live_talk
    end
    return false
  end
  
  def create_live_answers(live_talk, live_answer_hash)
    ori_weibo = live_talk.weibo
    weibo_hash = live_answer_hash.delete("weibo")
    LiveAnswer.transaction do
      weibo = self.rt_weibo(ori_weibo, weibo_hash)
      live_answer = live_talk.live_answers.create(:weibo => weibo)
      return live_answer
    end
    return false
  end
  
  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'], :access_token => omniauth["credentials"]["token"], :access_secret => omniauth["credentials"]["secret"] || "", :nickname => omniauth["info"]["nickname"])  
  end
  
  def bind_omniauth(omniauth)
    new_authen = Authentication.new(:provider => omniauth['provider'], :uid => omniauth['uid'], :access_token => omniauth["credentials"]["token"], :access_secret => omniauth["credentials"]["secret"] || "", :nickname => omniauth["info"]["nickname"]) 
    authentications << new_authen
  end
  
  def rt_weibo(weibo, new_weibo_params)
    new_weibo_params[:content] = Weibo::DEFAULT_RT_CONENT  if new_weibo_params[:content].length == 0
    to_parent = new_weibo_params.delete(:comment_to_parent) == "1"
    to_ori = new_weibo_params.delete(:comment_to_ori) == "1"
    
    # record weibo remote ip, Add by Vincent, 2011-11-29
    comment_hash = {:content => new_weibo_params[:content], :remote_ip => new_weibo_params[:remote_ip], :status => new_weibo_params[:status] || Comment::PUBLISHED}
    
    if to_parent
      if to_ori
        comment_to_ori_weibo(weibo, comment_hash)
      else
        comment_to_parent_weibo(weibo, comment_hash)
      end
    else
      if to_ori
        comment_to_parent_weibo(weibo.parent_weibo, comment_hash)
      end
    end
    
    new_weibo = self.weibos.build(new_weibo_params)
    new_weibo.parent_weibo_id = weibo.id
    if weibo.ori_weibo_id == 0
      weibo.rt_weibos << new_weibo
    else
      weibo.ori_weibo.rt_weibos << new_weibo if weibo.ori_weibo
      Weibo.increment_counter("rt_count", weibo.id)
    end
    new_weibo
  end
  
  def create_weibo(new_weibo_params)
    self.weibos.create(new_weibo_params)
  end
  
  def create_plain_text_weibo(content, remote_ip = nil, content_check_needed = false)
    weibo_content = {:content => content}
    weibo_content[:remote_ip] = remote_ip if remote_ip.present?
    weibo_content[:status] = Weibo::PENDING if content_check_needed
    
    self.weibos.create(weibo_content)
  end
  
  #the only protocol
  def comment_to_weibo(weibo, comment)
    if comment.delete(:rt_weibo) == "1"
      
      weibo_content = Weibo.format(comment[:content]) #{:content => xxx}
      weibo_content[:remote_ip] = comment[:remote_ip] if comment[:remote_ip].present?
      weibo_content[:status] = comment[:status] if comment[:status].present?
      
      rt_weibo(weibo, weibo_content) 
    end
    
    if comment.delete(:comment_to_ori_weibo) == "1"
      comment_to_ori_weibo(weibo, comment)
    else
      comment_to_parent_weibo(weibo, comment)
    end
  end
  
  def comment_to_parent_weibo(weibo, comment_hash)
    return if weibo.nil?
    unless comment_hash["article_id"]
      article_id = Weibo.weibo_article_id[weibo.ori_weibo_id_or_self_id]
      comment_hash["article_id"] = article_id if article_id
    end
    comment = self.comments.build(comment_hash)
    weibo.comments << comment
    if comment.parent_comment_id.nil?
      comment.comment_logs.create(:user_id => weibo.owner_id) if weibo.owner_id != self.id
    else
      comment.comment_logs.create(:user_id => comment.parent.user_id) if comment.parent.user_id != self.id
      comment.comment_logs.create(:user_id => weibo.owner_id) if weibo.owner_id != comment.parent.user_id && weibo.owner_id != self.id
    end
    #CommentNotification.create(:recipient_id => weibo.owner_id, :target => comment) unless weibo.owner_id == self.id
    comment
  end
  
  def comment_to_ori_weibo(weibo, comment_hash)
    unless comment_hash["article_id"]
      article_id = Weibo.weibo_article_id[weibo.ori_weibo_id_or_self_id]
      comment_hash["article_id"] = article_id if article_id
    end
    comment = self.comments.build(comment_hash.merge!(:ori_weibo_id => weibo.ori_weibo_id))
    Weibo.increment_counter("reply_count", weibo.ori_weibo_id)
    weibo.comments << comment
    # just make a notification to usre but not to stock
    # there is no check for this function
    weibo_user_id = weibo.owner_id
    comment.comment_logs.create(:user_id => weibo_user_id) unless weibo_user_id == self.id
    ori_weibo_user_id = weibo.ori_weibo.owner_id
    comment.comment_logs.create(:user_id => ori_weibo_user_id) unless ori_weibo_user_id  == self.id || ori_weibo_user_id == weibo_user_id
    comment
  end
  
  def delete_comment(comment)
    #self.comments.delete(comment)
    comment.destroy
  end
  
  def delete_weibo(weibo)
    self.weibos.destroy(weibo.id)
  rescue ActiveRecord::RecordNotFound
    logger.error "the weibo is not belong to curren user"
  end
  
  def generate_s_key_for_new_user
    begin  
      self.s_key = SecureRandom.urlsafe_base64(24)  
    end while User.exists?(:s_key => self.s_key)  
  end
  
  def can_delete_weibo(weibo)
    self.weibos_id.include?(weibo.id)
  end
  
  def is_same_user?(user)
    return false if user.blank?
    
    self.id == user.id
  end
  
  def is_followers_of?(user)
    user.follower_ids.include?(self.id)
  end
  
  def is_followings_of?(user)
    user.following_ids.include?(self.id)  
  end
  
  def is_weibo_owner?(weibo)
    return false if weibo.blank?
    self.id == weibo.owner_id and self.class.to_s == weibo.owner_type
  end
  
  def is_active?
    self.status == STATUS_ACTIVE
  end
  
  def is_supper_user?
    self.user_type == USER_TYPE_SUPPER
  end
  
  def activate
    self.status = STATUS_ACTIVE
    save!
  end
  
  def send_password_reset
    generate_token(:password_reset_token)
    
    self.password_reset_sent_at = Time.now  
    save!
    
    UserMailer.password_reset(self).deliver  
  end
  
  def send_activate_user
    generate_token(:activate_token)
    self.activate_sent_at = Time.now  
    save!
    
    UserMailer.activate_user(self).deliver
  end
  
  def resolve_email_host
    return if self.email.blank?
    
    host = email.split("@")[1]
    if host.downcase.strip == "gmail.com"
      "http://mail.google.com"
    else
      "http://mail." + host
    end
  end

  def is_guest_of?(live)
    live.all_guest_ids.include?(self.id)
  end

  def is_compere_of?(live)
    live.user_id == self.id
  end

  def is_audience_of?(live)
    !is_guest_of?(live) and !is_compere_of?(live)
  end

  def is_important_user_of?(live)
    is_guest_of?(live) or is_compere_of?(live)
  end

  def is_premium_user?
    true
  end

  def is_valid_premium_user?
    return false unless self.mn_account
    self.mn_account.try("account_valid?")
  end

  def is_premium_overdue_soon?
    return false unless self.mn_account
     self.mn_account.try("overdue_soon?")
  end

  def is_premium_overdue?
    return false unless self.mn_account
    self.mn_account.try("overdue?")
  end

  def mn_service_time
    return 0 unless self.mn_account
    return self.mn_account.service_time.to_i
  end

  def mn_service_end_at
    return 0 unless self.mn_account
    return 0 unless self.mn_account.service_end_at
    return self.mn_account.service_end_at.to_i
  end

  def mn_activated_from
    return "" unless self.mn_account
    return self.mn_account.last_activated_device || ""
  end

  def mn_last_payed_at
    return ""  unless self.mn_account
    return ""  unless self.mn_account.last_payment_at
    return self.mn_account.last_payment_at.to_i
  end

  def check_access_token(token)
    value = self.cache_access_token.value
    self.cache_access_token = self.access_token if value.blank?
    if (value = self.cache_access_token.value).blank?
      self.access_token = NBD::Utils.to_md5(Time.now.to_i.to_s)
      self.token_updated_at = Time.now.to_i.to_s
      if self.save
        self.cache_token_updated_at = self.token_updated_at
        self.cache_access_token = self.access_token
      end
    else
      return false if token != value
      updated_at = self.cache_token_updated_at.value
      self.cache_token_updated_at = self.token_updated_at if updated_at.blank?
      if self.cache_token_updated_at.value.blank? or (Time.at(self.cache_token_updated_at.value.to_i) + EXPIRE_ACCESS_TOKEN_TIME.minutes).past?
        self.access_token = NBD::Utils.to_md5(Time.now.to_i.to_s)
        self.token_updated_at = Time.now.to_i.to_s
        if self.save
          self.cache_token_updated_at = self.token_updated_at
          self.cache_access_token = self.access_token
        end
      end
    end
    return self.cache_access_token.value
  end

  def valid_access_token
    self.check_access_token(self.cache_access_token)
  end

  def create_mn_account_gift(current_device, gift_period, is_receive_sms, phone_no)
    MnAccount.create_gift_account(self.id, MnAccount::PLAN_TYPE_GIFT, current_device, gift_period, is_receive_sms, phone_no)
  end

  def pay_for_gms_article(gms_article)
    User.transaction do
      gms_article.increment!(:sales_quantity)
      self.decrement!(:credits, gms_article.cost_credits)
      # self.update_attribute(:credits,self.credits - gms_article.cost_credits)
      GmsAccountsArticle.create({:gms_account_id => self.gms_account.id, :user_id => self.id, :gms_article_id => gms_article.id, :cost_credits => gms_article.cost_credits})
      # self.gms_account.credit_logs.create({:user_id => self.id, :cmd => CreditLog::CMD_COST, :credits => gms_article.cost_credits, :product_type => CreditLog::PRODUCT_TYPE_GMS, :product_id => gms_article.id})
      create_gms_account_credit_log(CreditLog::CMD_COST, gms_article.cost_credits, CreditLog::PRODUCT_TYPE_GMS, gms_article.id)
    end
  end

  def refund_gms_article(gms_article)
    User.transaction do
      gms_account_article = GmsAccountsArticle.where(:user_id => self.id, :gms_article_id => gms_article.id).first
      self.increment!(:credits, gms_article.cost_credits)
      # self.update_attribute(:credits,self.credits + gms_account_article.cost_credits)
      gms_account_article.update_attribute(:is_receive_refund,GmsAccountsArticle::REFUND_CREDITS_STATUS)
      # self.gms_account.credit_logs.create({:user_id => self.id, :cmd => CreditLog::CMD_REFUND, :credits => gms_account_article.cost_credits, :product_type => CreditLog::PRODUCT_TYPE_GMS, :product_id => gms_article.id})
      create_gms_account_credit_log(CreditLog::CMD_REFUND, gms_account_article.cost_credits, CreditLog::PRODUCT_TYPE_GMS, gms_article.id)
      return gms_account_article.cost_credits
    end
  end

  def pay_for_credits(plan_type)
      self.increment!(:credits, GmsAccount::CREDITS[plan_type])
      # self.update_attribute(:credits,self.credits+GmsAccount::CREDITS[plan_type])
      # self.gms_account.credit_logs.create({:user_id => self.id,:cmd => CreditLog::CMD_PAY,:credits => GmsAccount::CREDITS[plan_type], :product_type => CreditLog::PRODUCT_TYPE_GMS, :product_id => 0})
      create_gms_account_credit_log(CreditLog::CMD_PAY, GmsAccount::CREDITS[plan_type], CreditLog::PRODUCT_TYPE_GMS, 0)
  end

  def update_access_tokens(accounts=[:gms_account,:mn_account])
      gms_access_token = self.gms_account.check_access_token('init') if (self.gms_account.present? && accounts.include?(:gms_account))
      mn_access_token = self.mn_account.check_access_token('init') if (self.mn_account.present? && accounts.include?(:mn_account))
      return {:gms_access_token => gms_access_token,:mn_access_token => mn_access_token}
  end

  def any_mn_account?
    mn_account.nil?
  end
  

  class << self
    
    #股市直播用户
    def stock_live_user
      find(SYS_USERS[:live_user_id])
    end
    
    def active_users(limit = 10, asso_hash = {})
      hot_objects("hot_cache:result:active_user", limit, asso_hash, SYSTEM_USER_IDS)
    end
    
    def authenticate(email, password)
      email = email.strip
      if email =~ /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
        user = where(:email => email).first
      else
        user = where(:nickname => email).first
      end
      if user
        if user.hashed_password == encrypt_password(password, user.salt)
          user
        end
      end
    end
    
    def recommend_users
      user_ids = ColumnsUser.all.map(&:user_id)
      
      User.find(user_ids)
    end
    
    def existed?(nickname)
      where(:nickname => nickname).first.present?
    end

    
    #TODO
    #def active_users(limit)
    #where(:status => STATUS_ACTIVE).order("id DESC").limit(limit)
    #end
    
  end
  
  private
  
  def generate_token(column)  
    begin  
      self[column] = SecureRandom.urlsafe_base64(24)
    end while User.exists?(column => self[column])  
  end

  def create_gms_account_credit_log(cmd, credits, product_type, product_id)
    self.gms_account.credit_logs.create({:user_id => self.id, :cmd => cmd, :credits => credits, :product_type => product_type, :product_id => product_id})
  end
  
end



# == Schema Information
#
# Table name: users
#
#  id                     :integer(4)      not null, primary key
#  email                  :string(64)      not null
#  nickname               :string(64)      not null
#  hashed_password        :string(64)      not null
#  salt                   :string(64)      not null
#  reg_from               :integer(4)      default(0)
#  user_type              :integer(4)      default(1)
#  auth_token             :string(32)      not null
#  status                 :integer(4)      default(0), not null
#  password_reset_token   :string(32)
#  password_reset_sent_at :datetime
#  activate_token         :string(32)
#  activate_sent_at       :datetime
#  followings_count       :integer(4)      default(0)
#  followers_count        :integer(4)      default(0)
#  stocks_count           :integer(4)      default(0)
#  weibos_count           :integer(4)      default(0)
#  created_at             :datetime
#  updated_at             :datetime
#
