#encoding: utf-8
class Jobs::VerifyApplePaymentJob
  include Premium::PremiumUtils
  @queue = :verify_apple_payment

  def self.perform(payment_id)
    payment = Payment.find(payment_id)
    return if payment.verifying?
    receipt_data = payment.receipt_data
    result = {}
    timeout(30) do
      result = verify_apple_puchase(receipt_data)
    end
    successful = (result["type"].to_i == payment.plan_type and result["status"].to_i == 0)
    File.open("#{Rails.root.to_s}/log/ttyj_appstore_verify_log.out", 'a') do |f|
      f.puts "===========verify payment id: #{payment.id}===================="
      f.puts "user_id / last_trade_num : #{payment.user.blank? ? '' : payment.user.nickname} / #{payment.service.last_trade_num}"
      f.puts "plan_type : #{payment.plan_type}"
      f.puts "created_at : #{payment.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
      f.puts "payment_at : #{payment.payment_at.strftime('%Y-%m-%d %H:%M:%S')}"
      f.puts "appstore_response : #{result['json_response']}"
      f.puts "status : #{result['status']}"
      f.puts "============== payment id: #{payment.id} status :#{successful ? '成功' : '失败'} ==================="
     end

    payment.set_success_from_apple_store_receipt if successful
    payment.set_faild_from_apple_store_receipt unless successful
  rescue TimeoutError => e
    Resque.enqueue(Jobs::VerifyApplePaymentJob, payment_id)
  end

  
end
