#encoding: utf-8
class MnAccount < ActiveRecord::Base
  if Rails.env.development?
    TOTAL_FEE = {0 => 0.01, 1 => 0.01, 2 => 0.01, 3 => 0.01}
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

  belongs_to :user  
  has_many :payments, :as => :service
  has_many :service_cards, :as => :service

  validates_format_of :phone_no, :with => /^(\d{11}|\d{0})$/
  scope :active, where(["service_end_at > ?", Time.now])
  scope :new_active, lambda{|time| where(["last_payment_at > ?", time.ago]) }
  scope :invalid_soon, lambda{|time| where(["service_end_at > ? and service_end_at < ?", time.ago, Time.now]) }
  scope :invalid, where(["service_end_at < ?", Time.now])

  def plan_type_str
    
    if self.plan_type == PLAN_TYPE_GIFT
      return "#{ACTIVE_FROM[self.last_active_from]}-赠送"
    else
      return "#{ACTIVE_FROM[self.last_active_from]}"
    end
    #  && self.last_active_from == ACTIVE_FROM_APPLE
    # return "安卓试用账号" if self.plan_type == PLAN_TYPE_GIFT && self.last_active_from == ACTIVE_FROM_ANDROID
    count = I18n.t("service_time.mn_account.type_#{self.plan_type}")
    "#{count}个月"
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

  def touch_success(plan_type, active_from)
    self.plan_type = plan_type
    self.last_active_from = active_from
    self.last_payment_at = Time.now
    month_count = I18n.t("service_time.mn_account.type_#{self.plan_type}")
    Rails.logger.debug "----------------------------#{month_count}"

    # self.service_end_at = service_end_at + month_count.months + 1.days if service_end_at > Time.now

    # self.service_end_at = Time.now + month_count.months + 1.days 

    if !service_end_at
      self.service_end_at = Time.now + month_count.months + 1.days
    elsif service_end_at > Time.now
      self.service_end_at = service_end_at + month_count.months + 1.days
    elsif service_end_at < Time.now
      self.service_end_at = Time.now + month_count.months + 1.days
    end
    save!
  end

  def touch_faild(plan_type)
    payment = self.payments.order("id desc").offset(1).first
    if payment
      self.plan_type = payment.plan_type
    else
      self.plan_type = nil
    end
    month_count = I18n.t("service_time.mn_account.type_#{plan_type}")
    self.service_end_at = self.service_end_at - month_count.months
    save!
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
    if temp_mn_account = user.mn_account
      self.bind_mn_account(temp_mn_account)
      return temp_mn_account
    else
      self.user_id = user.id if self.user_id.nil?
      self.save
      return self      
    end
  end

  def bind_mn_account(account)
    MnAccount.transaction do
    if self.created_at > account.created_at
      [:plan_type, :last_active_from, :last_activated_device, :last_payment_at,:last_trade_num,:gift_details, :is_receive_sms, :is_receive_credits].each do |method|
        account.send("#{method}=", self.send(method))
      end
    end
    account.service_end_at = self.service_end_at 
    account.service_end_at -= Time.now unless account.service.nil?
    self.payments.update_all(:service_id => account.id)
    self.destroy
    account.save
  end
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



end
