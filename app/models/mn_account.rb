#encoding: utf-8
class MnAccount < ActiveRecord::Base
  include PaymentAccount
  if Rails.env.development?
    TOTAL_FEE = {0 => 0.01, 1 => 0.01, 2 => 0.02, 3 => 0.03}
  else
    TOTAL_FEE = {0 => 60.0, 1 => 160.0, 2 => 300.0, 3 => 580.0}
  end

  RECEIVE_CREDITS = 26

  COUNT_DOWN_DAYS_ALERT = 3
  include Redis::Objects
  value :cache_access_token
  value :cache_token_updated_at

  ACTIVE_FROM_ALIPAY = 0
  ACTIVE_FROM_CARD = 1
  ACTIVE_FROM_APPLE = 2
  ACTIVE_FROM_ANDROID = 3

  PLAN_TYPE_GIFT = -1
  PLAN_TYPE_MONTH = 0
  PLAN_TYPE_THREE_MONTH = 1
  PLAN_TYPE_SIX_MONTH = 2
  PLAN_TYPE_YEAR = 3

  ONE_WEEK_GIFT_TIME = 7.days
  TWO_WEEK_GIFT_TIME = 14.days

  ACTIVE_FROM = {ACTIVE_FROM_ALIPAY => "支付宝", ACTIVE_FROM_CARD => "激活卡", ACTIVE_FROM_APPLE => "App Store",ACTIVE_FROM_ANDROID => "安卓"}
  PLAN_TYPE_NAMES = { PLAN_TYPE_MONTH => "一个月", PLAN_TYPE_THREE_MONTH => "三个月", PLAN_TYPE_SIX_MONTH => "六个月", PLAN_TYPE_YEAR => "一年"}  


  DEVICE_WEB = "web"
  DEVICE_IPHONE = "apple"
  DEVICE_ANDROID = "android"

  RECEIVE_SMS = 0

  DEVICE_NAMES = {ACTIVE_FROM_ALIPAY => DEVICE_WEB, DEVICE_WEB => DEVICE_WEB, ACTIVE_FROM_APPLE => DEVICE_IPHONE, ACTIVE_FROM_ANDROID => DEVICE_ANDROID}

  LEAST_LOGIN_COUNT = 3

# touzibao active accounts vars
  ACTIVE_USER = "touzibao::active_users"
  ACTIVE_USER_DETAILS = "touzibao::user_activity_details"
  RECEIVE_ACTIVE_USER_EMAILS = ["yangxue@nbd.com.cn", "maojinnan@nbd.com.cn", "caojun@nbd.com.cn", "zhouzhongwen@nbd.com.cn"] 
  # RECEIVE_ACTIVE_USER_EMAILS = ["348281683@qq.com", "zhouzhongwen@nbd.com.cn"] 

  belongs_to :user  
  has_many :payments, :as => :service
  has_many :service_cards, :as => :service

  validates_format_of :phone_no, :with => /^(\d{11}|\d{0})$/
  scope :active, where(["service_end_at > ?", Time.now])
  scope :new_active, lambda{|time| where(["last_payment_at > ?", time.ago]) }
  scope :invalid_soon, lambda{|time| where(["service_end_at > ? and service_end_at < ?", time.ago, Time.now]) }
  scope :invalid, where(["service_end_at < ?", Time.now])

  def plan_type_str
    
    plan_type_result = "#{ACTIVE_FROM[self.last_active_from]}"

    plan_type_result += "-赠送" if self.plan_type == PLAN_TYPE_GIFT
    return plan_type_result

    # if self.plan_type == PLAN_TYPE_GIFT
    #   return "#{ACTIVE_FROM[self.last_active_from]}-赠送"
    # else
    #   return "#{ACTIVE_FROM[self.last_active_from]}"
    # end
    #  && self.last_active_from == ACTIVE_FROM_APPLE
    # return "安卓试用账号" if self.plan_type == PLAN_TYPE_GIFT && self.last_active_from == ACTIVE_FROM_ANDROID
    # count = I18n.t("service_time.mn_account.type_#{self.plan_type}")
    # "#{count}个月"
  end

  def payed?
    self.service_end_at.present?
  end

  def account_valid?
    self.payed? && self.service_end_at.future?
  end

  def overdue_soon?
    self.account_valid? && (Time.now + 15.days > self.service_end_at)
  end

  def overdue?
    return true unless self.payed?

    self.payed? && self.service_end_at.past?
  end

  def service_time
    return 0 unless self.payed?
    self.overdue? ? 0 : ((self.service_end_at - Time.now) / (24 * 60 * 60)).to_i
  end

  def paid_for?(plan_type)
    return false if overdue?

    self.plan_type == plan_type
  end

  def is_receive_credits?
    self.is_receive_credits == 1
  end

  def touch_success(plan_type, active_from, payment_device)
    self.plan_type = plan_type
    self.last_active_from = active_from
    self.last_payment_at = Time.now
    self.last_activated_device = payment_device
    month_count = I18n.t("service_time.mn_account.type_#{self.plan_type}")
    Rails.logger.debug "----------------------------#{month_count}"

    # self.service_end_at = service_end_at + month_count.months + 1.days if service_end_at > Time.now

    # self.service_end_at = Time.now + month_count.months + 1.days 
    plan_type_period = month_count.months + 1.days
    period = Time.now + plan_type_period
    if self.service_end_at && self.service_end_at.future?
      self.service_end_at += plan_type_period
    else
      self.service_end_at = period
    end

    # if !service_end_at
    #   self.service_end_at = Time.now + month_count.months + 1.days
    # elsif service_end_at > Time.now
    #   self.service_end_at = service_end_at + month_count.months + 1.days
    # elsif service_end_at < Time.now
    #   self.service_end_at = Time.now + month_count.months + 1.days
    # end
    save!
  end

  def touch_faild(payment)
    #error: payment is not the last one but the last success one!
    # payment = self.payments.order("id desc").first
    # if payment
    #   self.plan_type = payment.plan_type
    # else
    #   self.plan_type = nil
    # end
    month_count = I18n.t("service_time.mn_account.type_#{payment.plan_type}")
    self.service_end_at = self.service_end_at - month_count.months
    save!
  end

  def old_touch_faild(plan_type)
    #error: payment is not the last one but the last success one!
    # payment = self.payments.order("id desc").first
    if payment
      self.plan_type = payment.plan_type
    else
      self.plan_type = nil
    end
    month_count = I18n.t("service_time.mn_account.type_#{plan_type}")
    self.service_end_at = self.service_end_at - month_count.months
    save!
  end


  def appstore_status(type)
    p = self.payments.where("service_type = 'MnAccount' and service_id = ?",self.id).order('id desc').first
    p.status == type
  end

  def last_appstore_status_name
    p = last_payment
    return "认证成功" if p.status == Payment::STATUS_SUCCESS
    return "等待认证" if p.status == Payment::STATUS_WAITE
    return "认证失败" if p.status == Payment::STATUS_FAILED
  end

  def last_payment
    p = self.payments.order('id DESC').first
  end

  def self.create_gift_account(user_id, plan_type, current_device, gift_period, is_receive_sms, phone_no)
    time = Time.now
    service_end = time + gift_period
    self.create(:user_id => user_id, 
                :plan_type => plan_type, 
                :last_active_from => current_device, 
                :last_activated_device => DEVICE_NAMES[current_device], 
                :last_payment_at => time, 
                :service_end_at => service_end, 
                :is_receive_sms => is_receive_sms, 
                :phone_no => phone_no, 
                :gift_details => "赠送#{gift_period.to_i/(60*60*24)}天")
  end

  def check_access_token(token = 'init')
    update_access_token if token == 'init'
    unless token == 'init'
      value = self.cache_access_token.value
      return false if token != value
      self.cache_access_token ||= self.access_token
      update_access_token if self.cache_access_token.value.blank?
      self.cache_token_updated_at ||= self.access_token_updated_at
      update_access_token if (self.cache_token_updated_at.value.blank? || (Time.at(self.cache_token_updated_at.value.to_i) + 3.months).past?)
    end
    return self.cache_access_token.value
  end

  def update_access_token
    self.access_token = NBD::Utils.to_md5(Time.now.to_i.to_s)
    self.access_token_updated_at = Time.now.to_i.to_s
    if self.save
      self.cache_token_updated_at = self.access_token_updated_at
      self.cache_access_token = self.access_token
    end
  end

  def valid_access_token
    self.check_access_token(self.cache_access_token)
  end

  def bind_user(user)
    return false if self.binded?
    if user.any_mn_account?
      self.update_attribute(:user_id, user.id)
      return self
    end
    return self.bind_mn_account(user.mn_account)
  end

  def bind_mn_account(account)
    MnAccount.transaction do
      keep_fields = ["id", "user_id", "created_at", "service_end_at", "is_receive_credits", "is_receive_sms", "gift_details", "access_token_updated_at", "access_token"]
      effective_fields = MnAccount.column_names - keep_fields
      effective_fields.each do |method|
        account.send("#{method}=", self.send(method))
      end
      over_peroid = (self.service_end_at && self.service_end_at.future?) ? (self.service_end_at - Time.now) : 0
      unless account.service_end_at
        account.service_end_at = self.service_end_at
      else
        account.service_end_at += over_peroid
      end
      self.payments.update_all(:service_id => account.id)
      account.save
      self.destroy
    end
    return account
  end

  def binded?
    self.user_id.present?
  end

  def self.rand_trade_num
    old_trade_nums = MnAccount.select([:last_trade_num]).map(&:last_trade_num)
    num_word_arr = ((0..9).to_a) + ("a".."z").to_a
    count = num_word_arr.size
    str = ""
    while(true) do
      arr = []
      6.times do
        arr << num_word_arr[rand(count)]
      end
      if !old_trade_nums.index(arr.join(""))
        str = arr.join("")
        break
      end
    end
    return str
  end

  def record_active_user
    active_users = Redis::HashKey.new(ACTIVE_USER, Redis::Objects.redis)
    user_activity_details = Redis::Set.new("#{ACTIVE_USER_DETAILS}_#{self.id}", Redis::Objects.redis)
    user_activity_details << Time.now.strftime('%Y-%m-%d')
    active_users[self.id] = user_activity_details.count if user_activity_details.count >= LEAST_LOGIN_COUNT
  end

  def self.last_week_user_activity_cache_flush!
      Redis::HashKey.new(ACTIVE_USER, Redis::Objects.redis).clear
      redis = Redis::Objects.redis
      redis.select 12
      keys = redis.keys "#{ACTIVE_USER_DETAILS}_*"
      keys.each do |key|
        redis.del key
      end    
  end

  def create_json_result
    user = self.user
    user_info = Hash.new("")
    user_info = {:id => user.id, :nickname => user.nickname, :email => user.email} if user
       {
        :access_token => self.valid_access_token,
        :trade_num => self.last_trade_num.nil? ? "" : self.last_trade_num,
        :user_info => {
          :user_id => user_info[:id],
          :nickname => user_info[:nickname],
          :email => user_info[:email],
        },
        :touzibao_account => {
          :expiry_at => self.service_end_at.to_i * 1000,
          :alert => {
          :today => Time.now.to_i * 1000,
          :count_down_days_alert => MnAccount::COUNT_DOWN_DAYS_ALERT
          },
          :is_valid => self.account_valid?,
          :plan_type => self.try(:plan_type),
          :last_activated_from => self.last_activated_device.nil? ? "" : self.last_activated_device,
          :last_payment_at => self.last_payment_at.to_i * 1000
        }
      }
  end  

end
