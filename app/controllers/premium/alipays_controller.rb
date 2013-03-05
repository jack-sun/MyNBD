class Premium::AlipaysController < ApplicationController
  include Premium::PremiumUtils
  if Rails.env.development?
    GMS_ACCOUNT_NOTIFY = 'http://www.nbd.cn/premium/alipay/notify_gms'
  else
    GMS_ACCOUNT_NOTIFY = 'http://www.nbd.com.cn/premium/alipay/notify_gms'
  end
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

  def notify_mobile
    query_string = nil
    if request.get?
      query_string = request.query_string
    else
      query_string = request.raw_post
    end
Rails.logger.info "-----------------query_string -----#{query_string}"

    notify = Alipay::Notification.new(query_string)
    return render :text => false unless verify_sign(query_string)
    if notify.status == "TRADE_SUCCESS"
      @payment = Payment.find(notify.out_trade_no.split("_").last)
      @payment.set_success_from_notify(notify)
      if @payment.service.class == MnAccount
        if request.post? and Rails.env.production?
          return render :text => "success"
        else
          json_result = create_json_result(@payment.user.mn_account)
          str_result = "nbd://touzibao?response=#{json_result}"
          return render :text => str_result
          # return render :json => create_json_result(@payment.user.mn_account)
        end
      end
    else
      return render :text => "faild"
    end

  end

  def notify_gms
    query_string = nil
    if request.get?
      query_string = request.query_string
    else
      query_string = request.raw_post
    end
    notify = Alipay::Notification.new(query_string)
    if notify.status == "TRADE_SUCCESS"
      @payment = Payment.find(notify.out_trade_no.split("_").last)
      Payment.transaction do
        @payment.set_success_from_notify(notify)
      end
      flash[:note] = {:play_type => @current_user.gms_account.plan_type}
      after_sign_in_and_redirect_to(@current_user)
    else
      return render :text => "faild"
    end
  end
end
