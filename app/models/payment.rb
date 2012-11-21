require 'cgi'
class Payment < ActiveRecord::Base
  belongs_to :service, :polymorphic => :true  
  belongs_to :user
  belongs_to :service_card
  STATUS_SUCCESS = 1
  STATUS_WAITE = 0
  STATUS_FAILED = 2
  PAY_FROM_ALIPAY = 0
  PAY_FROM_CARD = 1
  PAY_FROM_APPLE = 2

  scope :waiting_payments, where(:status => STATUS_WAITE)
  scope :success_payments, where(:status => STATUS_SUCCESS)
  scope :failed_payments, where(:status => STATUS_FAILED) 
  def success?
    status == STATUS_SUCCESS
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
      service.touch_success(self.plan_type, MnAccount::ACTIVE_FROM_ALIPAY)
      save!
    end
  end

  def set_success_from_card(card)
    return if self.success?
    Payment.transaction do
      self.status = STATUS_SUCCESS
      self.payment_type = PAY_FROM_CARD
      self.service_card_id = card.id
      service.touch_success(self.plan_type, MnAccount::ACTIVE_FROM_CARD)
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
      service.last_activated_device = MnAccount::DEVICE_IPHONE
      service.touch_success(self.plan_type, MnAccount::ACTIVE_FROM_APPLE)
      self.user_id = service.user_id
      self.receipt_data = receipt
      self.payment_at = Time.now
      self.save!
    end
  end

  def active_from_alipay?
    self.payment_type == PAY_FROM_ALIPAY
  end

  def out_trade_no
    "#{Settings.app_env}_#{Time.now.to_i.to_s}_#{self.id}"
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
end
