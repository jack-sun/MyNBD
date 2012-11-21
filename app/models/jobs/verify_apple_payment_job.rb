class Jobs::VerifyApplePaymentJob
  include Premium::PremiumUtils
  @queue = :verify_apple_payment

  def self.perform(receipt_data, plan_type)
    result = {}
    timeout(10) do
      result = verify_apple_puchase(receipt_data)
    end
    if result["type"] == plan_type and result["status"] == 0
      Payment.set_success_from_apple_store_receipt(receipt_data)
    else
      Payment.set_faild_from_apple_store_receipt(receipt_data)
    end

  rescue TimeoutError => e
    Resque.enqueue(Jobs::VerifyApplePaymentJob, receipt_data, plan_type)
  end

  
end
