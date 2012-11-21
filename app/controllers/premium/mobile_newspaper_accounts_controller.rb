#encoding: utf-8
class Premium::MobileNewspaperAccountsController < ApplicationController
  layout "mobile_newspaper"

  include Premium::PremiumUtils
  before_filter :current_user
  before_filter :authorize , :except => [:introduce]
  
  #TOTAL_FEE = {1 => 19.8, 2 => 58, 3 => 108, 4 => 198}


  # create payment from alipay
  #
  def subscribe
    init_accounts(params[:plan_type], MnAccount::ACTIVE_FROM_ALIPAY)
    return render :new unless @current_account.errors.blank?
    @payment = init_payment_with(@current_account, params[:plan_type].to_i)

    options = {}
    options[:out_trade_no] = @payment.out_trade_no
    options[:amount] = @payment.payment_total_fee.to_s
    options[:body] = "每日经济新闻xxxxx 订单号：#{@payment.out_trade_no}"
    count = I18n.t("service_time.mn_account.type_#{params[:plan_type]}")
    options[:subject] = "订阅每日经济新闻手机报服务 #{count}个月 手机号：#{params[:mobile_no]}"
    return redirect_to make_url_by_query_string(options)
  end

  # create payment from activate card
  #
  def activate
    if !@current_user.mn_account.try(:phone_no).blank? and params[:mobile_no] =~ /^\d{11}$/
      @phone_no_error = true
      params[:type] = "1"
      return render :new
    end

    flash[:captcha_error] = nil
    if !simple_captcha_valid?("simple_captcha")
      flash[:captcha_error] = "验证码错误！"
      params[:type] = "1"
      return render :action => "new"
    end

    @service_card = ServiceCard.where(:password => params[:password]).first

    if !@service_card or !@service_card.status_valid?
      @password_error = true
      params[:type] = "1"
      return render :new
    end

    init_accounts(@service_card.card_type, MnAccount::ACTIVE_FROM_CARD)
    init_payment_with(@current_account, @service_card.card_type)
    @payment.set_success_from_card(@service_card)

    return redirect_to success_premium_mobile_newspaper_account_url
  end

  # mn_account detail view
  #
  def show
    @account = @current_user.mn_account
  end

  # actions for payment status
  #

  def success
    @account = @current_user.mn_account
    @payment = @current_user.payments.last
  end

  def waiting
  end

  def failure
  end

  def introduce
  end

  def new
    @current_account = @current_user.mn_account
  end



  
end
