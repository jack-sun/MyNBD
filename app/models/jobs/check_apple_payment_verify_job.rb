#encoding: utf-8
class Jobs::CheckApplePaymentVerifyJob
  include Premium::PremiumUtils
  @queue = :verify_apple_payment
  def self.perform
    payments = Payment.get_preverify_payments
    payments.each do |payment|
      Resque.enqueue(Jobs::VerifyApplePaymentJob, payment.id)
    end
  end
end
