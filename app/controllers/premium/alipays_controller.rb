#encoding: utf-8
class Premium::AlipaysController < ApplicationController
  include Premium::PremiumUtils

  def notify
    query_string = request.get? ? request.query_string : request.raw_post
    Rails.logger.info "-----------------query_string -----#{query_string}"

    notify = Alipay::Notification.new(query_string)
    return render :text => false unless verify_sign(query_string)
    if notify.status == "TRADE_SUCCESS" || notify.params['result'] == 'success'
      @payment = Payment.find(notify.out_trade_no.split("_").last)
      @payment.set_success_from_notify(notify)

      if request.post? and Rails.env.production?
        return render :text => "success"
      else
        if @payment.service.class == MnAccount
          return redirect_to premium_mobile_newspaper_account_url
        elsif @payment.service.class == GmsAccount
          flash[:note] = {:plan_type => GmsAccount::PLAN_TYPE[@current_user.gms_account.plan_type]}
          return after_sign_in_and_redirect_to_gms(@current_user)
        end
      end

    else
      return render :text => "faild"
    end

  end


  def wap_notify
    query_string = request.get? ? request.query_string : request.raw_post
    Rails.logger.info "-----------------query_string -----#{query_string}"
    File.open("#{Rails.root}/log/alipay_debug.out", "a") do |f|
      f.puts "============ start ==============="
      f.puts "Time:#{Time.now}       request_method: #{request.method}"
      f.puts "query_string:#{query_string}"
    end
    return render :text => false unless verify_sign(query_string, request.get?)
    notify = Alipay::Notification.new(query_string)
    notify_data = notify.params['notify_data']
    if (request.get? && notify.params['result'] == 'success') || (request.post? && trade_succeed?(notify_data))
      if request.get? 
        @payment = Payment.find(notify.out_trade_no.split("_").last)
        @payment.set_success_from_wap_notify(notify, "get")
      elsif request.post?
        @payment = Payment.find(get_specify_node_data_from_xml(notify_data, 'notify', 'out_trade_no').split("_").last)
        @payment.set_success_from_wap_notify(notify, "post")
      end

      File.open("#{Rails.root}/log/alipay_debug.out", "a") do |f|
        f.puts "verify_result: success"
        f.puts "payment(#{@payment.id}) and mn_account(#{@payment.service.id}) completed their operation!"
        f.puts "============= end =============="
      end

      if request.post? and Rails.env.production?
        return render :text => "success"
      else
        if @payment.service.class == MnAccount
          return redirect_to premium_mobile_newspaper_account_url
          # return render :text => "您已成功购买！请关闭本页面" 
        end
      end
    else
      File.open("#{Rails.root}/log/alipay_debug.out", "a") do |f|
        f.puts "verify_result: false"
        f.puts "============= end =============="
      end      
      return render :text => "faild"
    end

  end




# refactory by tony
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
        end
      end
    else
      return render :text => "faild"
    end

  end

#   def notify_gms
#     query_string = nil
#     if request.get?
#       query_string = request.query_string
#     else
#       query_string = request.raw_post
#     end
#     notify = Alipay::Notification.new(query_string)
#     if notify.status == "TRADE_SUCCESS"
#       @payment = Payment.find(notify.out_trade_no.split("_").last)
#       Payment.transaction do
#         @payment.set_success_from_notify(notify)
#       end
#       flash[:note] = {:plan_type => GmsAccount::PLAN_TYPE[@current_user.gms_account.plan_type]}
#       after_sign_in_and_redirect_to_gms(@current_user)
#     else
#       return render :text => "faild"
#     end
#   end

  private

  def after_sign_in_and_redirect_to_gms(user, redirect_back = false)
    if session[:jump_to_gms].present?
      to_url = session[:jump_to_gms]
      session[:jumpto] = nil
      session[:jump_to_gms] = nil
      return redirect_to to_url.to_s
    end
    if session[:jumpto].present?
      to_url = session[:jumpto]
      session[:jumpto] = nil
        
      redirect_to to_url.to_s
      return 
    elsif (params[:come_back] == "1" or redirect_back) and request.env["HTTP_REFERER"]
      redirect_to :back
      return 
    else
      redirect_to user_url(user)
      return
    end
  end

  def trade_succeed?(notify_data)
    trade_status = get_specify_node_data_from_xml(notify_data, 'notify', 'trade_status')
    trade_status == "TRADE_FINISHED" || trade_status == "TRADE_SUCCESS"
  end
end
