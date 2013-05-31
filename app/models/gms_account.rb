#encoding: utf-8
class GmsAccount < ActiveRecord::Base
  include PaymentAccount

  include Redis::Objects
  value :cache_access_token
  value :cache_token_updated_at

	belongs_to :user
  has_many :credit_logs, :as => :product
  has_many :payments, :as => :service
	before_create :generate_token

  scope :paid, where(" plan_type != -1 ")
  scope :un_paid, where( "plan_type = -1")

  ACCESS_TOKEN_EXPIRED_TIME = 10.minutes

  ACCESS_TOKEN_INIT = 'init'

  if Rails.env.development?
    TOTAL_FEE = {0 => 0.01, 1 => 0.02, 2 => 0.03 }
    # TOTAL_FEE = {0 => 3000, 1 => 20000 }
  else
    TOTAL_FEE = {0 => 3000, 1 => 20000, 2 => 100000 }
    # TOTAL_FEE = {1 => 3000, 2 => 20000 }
  end

  CREDITS = {0 => 300, 1 => 4000, 2 => 25000}

  PLAN_TYPE = {0 => "基本套餐", 1 => "高级套餐", 2 => "钻石套餐"}

  ACTIVE_FROM_ALIPAY = 0
  ACTIVE_FROM_CARD = 1
  ACTIVE_FROM_APPLE = 2
  ACTIVE_FROM_ANDROID = 3

  ACTIVE_FROM = {ACTIVE_FROM_ALIPAY => "支付宝", ACTIVE_FROM_CARD => "激活卡", ACTIVE_FROM_APPLE => "App Store",ACTIVE_FROM_ANDROID => "安卓"}

	def check_access_token(token=ACCESS_TOKEN_INIT)

    update_access_token if token == ACCESS_TOKEN_INIT

    flush_access_token_to_cache if self.cache_access_token.value.blank?

    return false if token != self.cache_access_token.value && token != ACCESS_TOKEN_INIT

    update_access_token if (Time.at(self.cache_token_updated_at.value.to_i) + ACCESS_TOKEN_EXPIRED_TIME).past?

    flush_access_token_to_cache

    return self.cache_access_token.value
  end


  def touch_success(plan_type, active_from, payment_device)
    self.plan_type = plan_type
    self.last_active_from = active_from
    self.last_payment_at = Time.now
    self.last_activated_device = payment_device
    self.save
    user = self.user
    user.pay_for_credits(plan_type)
  end

  private
  
  def generate_token
    self.access_token = NBD::Utils.to_md5(Time.now.to_i.to_s)
    self.access_token_updated_at = Time.now
  end

  def update_access_token
    generate_token
    self.save
  end

  def flush_access_token_to_cache
    self.reload
    self.cache_token_updated_at = self.access_token_updated_at.to_i.to_s
    self.cache_access_token = self.access_token
  end
end
