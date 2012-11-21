#encoding: utf-8
class MnAccount < ActiveRecord::Base
  if Rails.env.development?
    TOTAL_FEE = {0 => 0.01, 1 => 0.01, 2 => 0.01, 3 => 0.01}
  else
    TOTAL_FEE = {0 => 60.0, 1 => 160.0, 2 => 300.0, 3 => 580.0}
  end

  COUNT_DOWN_DAYS_ALERT = 3
  ACTIVE_FROM_ALIPAY = 0
  ACTIVE_FROM_CARD = 1
  ACTIVE_FROM_APPLE = 2
  ACTIVE_FROM_APPLE_GIFT = -1
  ACTIVE_FROM_ANDROID_GIFT = -2
  ACTIVE_FROM = {ACTIVE_FROM_ALIPAY => "支付宝", ACTIVE_FROM_CARD => "激活卡", ACTIVE_FROM_APPLE => "apple store", ACTIVE_FROM_APPLE_GIFT => "苹果账户赠送"}
  DEVICE_WEB = "web"
  DEVICE_IPHONE = "apple"
  DEVICE_ANDROID = "android"
  SERVICE_TYPE_APPLE_GIFT = -1
  SERVICE_TYPE_ANDROID_GIFT = -2
  belongs_to :user  
  has_many :payments, :as => :service
  has_many :service_cards, :as => :service

  validates_format_of :phone_no, :with => /^(\d{11}|\d{0})$/
  scope :active, where(["service_end_at > ?", Time.now])
  scope :new_active, lambda{|time| where(["last_payment_at > ?", time.ago]) }
  scope :invalid_soon, lambda{|time| where(["service_end_at > ? and service_end_at < ?", time.ago, Time.now]) }
  scope :invalid, where(["service_end_at < ?", Time.now])

  def plan_type_str
    return "苹果试用账号" if self.plan_type == SERVICE_TYPE_APPLE_GIFT
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

  def touch_success(plan_type, active_from)
    self.plan_type = plan_type
    self.last_active_from = active_from
    self.last_payment_at = Time.now
    month_count = I18n.t("service_time.mn_account.type_#{self.plan_type}")
    Rails.logger.debug "----------------------------#{month_count}"
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

  def self.create_gift_account(user_id, plan_type)
    time = Time.now
    service_end = time + 7.days
    if plan_type == SERVICE_TYPE_APPLE_GIFT
      self.create(:user_id => user_id, :plan_type => SERVICE_TYPE_APPLE_GIFT, :last_active_from => ACTIVE_FROM_APPLE_GIFT, :last_activated_device => DEVICE_IPHONE, :last_payment_at => time, :service_end_at => service_end)
    elsif plan_type == SERVICE_TYPE_ANDROID_GIFT
      self.create(:user_id => user_id, :plan_type => SERVICE_TYPE_ANDROID_GIFT, :last_active_from => ACTIVE_FROM_ANDROID_GIFT, :last_activated_device => DEVICE_ANDROID, :last_payment_at => time, :service_end_at => service_end)
    end
  end
end
