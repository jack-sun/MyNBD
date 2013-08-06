#encoding: utf-8
require 'cgi'
class Payment < ActiveRecord::Base

  include Premium::PremiumUtils

  belongs_to :service, :polymorphic => :true  
  belongs_to :user
  belongs_to :service_card
  STATUS_SUCCESS = 1
  STATUS_WAITE = 0
  STATUS_FAILED = 2
  STATUS_VERIFYING = 3
  STATUS_ALL = 9
  PAY_FROM_ALIPAY = 0
  PAY_FROM_CARD = 1
  PAY_FROM_APPLE = 2

  scope :waiting_payments, where(:status => STATUS_WAITE)
  scope :success_payments, where(:status => STATUS_SUCCESS)
  scope :failed_payments, where(:status => STATUS_FAILED) 
  scope :appstore, where("receipt_data is not null")
  scope :verify_status, lambda { |status| where(:status => status) }
  def success?
    status == STATUS_SUCCESS
  end

  def faild?
    !success?
  end

  def set_success_from_wap_notify(notify, request_method)
#params={"out_trade_no"=>"tzb_preview_1367912791_1133", 
# "request_token"=>"requestToken",
#  "result"=>"success", 
#  "trade_no"=>"2013050731555240", 
#  "sign"=>"703e22a4c79f46e127553b6343bbd6a6",
#  "sign_type"=>"MD5"}

    return if self.success?
    Payment.transaction do
      self.status = STATUS_SUCCESS
      if request_method == "get"
        self.trade_no = CGI.unescape(notify.trade_no)
      elsif request_method == "post"
        self.trade_no = CGI.unescape(get_specify_node_data_from_xml(notify.params['notify_data'], 'notify', 'out_trade_no'))
        self.payment_type = PAY_FROM_ALIPAY
        self.buyer_email = CGI.unescape(get_specify_node_data_from_xml(notify.params['notify_data'], 'notify', 'buyer_email'))
        self.trade_type = CGI.unescape(get_specify_node_data_from_xml(notify.params['notify_data'], 'notify', 'payment_type'))
      end
      self.raw_trade = CGI.unescape notify.raw
      self.payment_at = Time.now
      self.user_id = service.user_id
      service.touch_success(self.plan_type, MnAccount::ACTIVE_FROM_ALIPAY, self.payment_device)
      save!
    end
  end

  def set_success_from_notify(notify)
    return if self.success?
    Payment.transaction do
      self.status = STATUS_SUCCESS
      self.trade_no = CGI.unescape(notify.trade_no)
      self.payment_type = PAY_FROM_ALIPAY
      self.buyer_email =CGI.unescape notify.buyer_email
      self.trade_type = CGI.unescape notify.payment_type
      self.raw_trade = CGI.unescape notify.raw
      self.payment_at = Time.now
      self.user_id = service.user_id
      service.touch_success(self.plan_type, MnAccount::ACTIVE_FROM_ALIPAY, self.payment_device)
      save!
    end
  end

  def set_success_from_card(card)
    return if self.success?
    Payment.transaction do
      self.status = STATUS_SUCCESS
      self.payment_type = PAY_FROM_CARD
      self.service_card_id = card.id
      service.touch_success(self.plan_type, MnAccount::ACTIVE_FROM_CARD, self.payment_device)
      card.status = ServiceCard::STATUS_ACTIVATED
      self.payment_at = Time.now
      card.activated_at = Time.now
      card.save!
      save!
    end
  end

  def set_waiting_from_apple_store_receipt(receipt)
    Payment.transaction do
      self.status = STATUS_WAITE
      self.payment_type = PAY_FROM_APPLE
      # service.last_activated_device = MnAccount::DEVICE_IPHONE
      service.touch_success(self.plan_type, MnAccount::ACTIVE_FROM_APPLE, MnAccount::DEVICE_IPHONE)
      self.user_id = service.user_id
      self.receipt_data = receipt
      self.payment_at = Time.now
      self.save!
    end
  end

  def active_from_alipay?
    self.payment_type == PAY_FROM_ALIPAY
  end

  def out_trade_no(product = 'ttyj', device = 'web')
    "#{product}_#{device}_#{Settings.app_env}_#{Time.now.to_i.to_s}_#{self.id}"
  end

  def verifying?
    status == STATUS_VERIFYING
  end


  def set_faild_from_apple_store_receipt
    Payment.transaction do
      self.status = STATUS_FAILED
      self.service.touch_faild(self)
      self.save!
    end
  end

  #old set_faild_from_apple_store_receipt
  def old_set_faild_from_apple_store_receipt
    Payment.transaction do
      self.status = STATUS_FAILED
      self.service.touch_faild(self.plan_type)
      self.save!
    end
  end

  def set_success_from_apple_store_receipt
    # Payment.update_all({:status => STATUS_SUCCESS}, {:receipt_data => receipt})
    Payment.transaction do
      self.status = STATUS_SUCCESS
      self.save!
    end
  end


  def self.set_faild_from_apple_store_receipt(receipt)
    payment = Payment.waiting_payments.where(:receipt_data => receipt).first
    Payment.transaction do
      payment.status = STATUS_FAILED
      payment.service.touch_faild(payment.plan_type)
      payment.save!
    end
  end

  def self.set_success_from_apple_store_receipt(receipt)
    Payment.update_all({:status => STATUS_SUCCESS}, {:receipt_data => receipt})
  end

  def apple_verify_name
    return "等待" if self.status == STATUS_WAITE
    return "成功" if self.status == STATUS_SUCCESS
    return "失败" if self.status == STATUS_FAILED
  end

  def self.init_payment_with(account, plan_type)
    account.payments.create(:payment_total_fee => account.total_fee(plan_type), :user_id => account.user.id, :plan_type => plan_type, :status => Payment::STATUS_WAITE)
  end  

  def generate_alipay_params(pay_from_wap = false)
    count = I18n.t("service_time.mn_account.type_#{self.plan_type}")
    unless pay_from_wap
      alipay_params = {
        :partner => ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT,
        :out_trade_no => self.out_trade_no,
        :total_fee => self.payment_total_fee.to_s,
        :seller_email => ActiveMerchant::Billing::Integrations::Alipay::EMAIL,
        :notify_url => ActiveMerchant::Billing::Integrations::Alipay::NOTIFY_URL,
        :body => "Mobile每日经济新闻xxxxx 订单号：#{self.out_trade_no}",
        :"_input_charset" => 'utf-8',
        :service => ActiveMerchant::Billing::Integrations::Alipay::Helper::CREATE_DIRECT_PAY_BY_USER,
        :payment_type => "1",
        :return_url => ActiveMerchant::Billing::Integrations::Alipay::NOTIFY_URL
      }
      alipay_params[:subject] = if self.service_type == 'MnAccount'
        "订阅每日经济新闻天天赢家服务 #{count}个月 手机号：#{self.service.phone_no}"
      elsif self.service_type == 'GmsAccount'
        "购买投资宝股东大会实录#{GmsAccount::PLAN_TYPE[self.plan_type]} 用户信息：#{self.service.user.id} / #{self.service.user.nickname}"
      end
      # if Rails.env.development?
      #   alipay_params = alipay_params.merge({:return_url => ActiveMerchant::Billing::Integrations::Alipay::NOTIFY_URL})
      # end
    else
      alipay_params = {
        :format => "xml",
        :partner => ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT,
        #TODO
        :req_data => "<direct_trade_create_req><subject>订阅每日经济新闻天天赢家服务 #{count}个月 手机号：#{self.service.phone_no}</subject><out_trade_no>tzb_#{self.out_trade_no('ttyj','iphone')}</out_trade_no><total_fee>#{self.payment_total_fee.to_s}</total_fee><seller_account_name>#{ActiveMerchant::Billing::Integrations::Alipay::EMAIL}</seller_account_name><call_back_url>#{ActiveMerchant::Billing::Integrations::Alipay::WAP_NOTIFY_URL}</call_back_url><notify_url>#{ActiveMerchant::Billing::Integrations::Alipay::WAP_NOTIFY_URL}</notify_url></direct_trade_create_req>",
        :req_id => Time.now.to_i.to_s,
        :sec_id => "MD5",
        :service => Settings.wap_alipay_token_service,
        :v => "2.0"
      }
    end
    return alipay_params      
  end

  def self.get_preverify_payments
    payments = Payment.waiting_payments.appstore
    payments.update_all(:status => Payment::STATUS_VERIFYING)
    return payments
  end
end
