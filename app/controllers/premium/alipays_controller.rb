class Premium::AlipaysController < ApplicationController
  include Premium::PremiumUtils

  def notify
    query_string = nil
    if request.get?
      query_string = request.query_string
    else
      query_string = request.raw_post
    end
Rails.logger.info "-----------------query_string -----#{query_string}"

    notify = Alipay::Notification.new(query_string)
    return render :text => false unless verify_sign(query_string)
    #return render :text => false unless verify_request(notify.notify_id)

#   return render :text => "success" if request.post?

#   if notify.status == "TRADE_SUCCESS"
#     @payment = Payment.find(notify.out_trade_no.split("_").last)
#     @payment.set_success_from_notify(notify)
#     if @payment.service.class == MnAccount
#       redirect_to premium_mobile_newspaper_account_url
#     end
#   end
    if notify.status == "TRADE_SUCCESS"
      @payment = Payment.find(notify.out_trade_no.split("_").last)
      @payment.set_success_from_notify(notify)
      if @payment.service.class == MnAccount
        if request.post? and Rails.env.production?
          return render :text => "success"
        else
          return redirect_to premium_mobile_newspaper_account_url
        end
      end
    else
      return render :text => "faild"
    end

  end
end
