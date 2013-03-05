#encoding:utf-8
class Api::UsersController < ApplicationController
  skip_filter :current_user
  before_filter :current_mn_account_by_token, :only => [:destroy, :account,:create,:sign_in]# :payment_notify]
  before_filter :authorize_mn_account, :only => [:account]
  before_filter AppKeyFilter
  skip_before_filter :verify_authenticity_token, :only => [:payment_notify]

  attr_accessor :current_device

  include Premium::PremiumUtils

  def create
    @user = User.new(:nickname => params[:nickname], :email => params[:email], :password => params[:password], :password_confirmation => params[:phone_no].blank? ? params[:password_confirmation] : params[:password])    
    gift_period = params[:phone_no].blank? ? MnAccount::ONE_WEEK_GIFT_TIME : MnAccount::TWO_WEEK_GIFT_TIME
    is_receive_sms = false
    last_active_from = current_device
    if @user.save
      if @mn_account
        if @mn_account.binded?
          @user.create_mn_account_gift(last_active_from, gift_period, is_receive_sms, params[:phone_no])
        else
          @mn_account = @mn_account.bind_user(@user)
        end
      else
        @user.create_mn_account_gift(last_active_from,gift_period,is_receive_sms,params[:phone_no])
      end
      @user.reload

      update_user_session @user

      return render :json => create_json_result(@user.mn_account)
    else
      error = {}
      @user.errors.each do |k, v|
        error[k] = v
      end
      return render :json => {:error => error}, :status => 401
    end
  end

  def account
    return render :json => create_json_result(@mn_account)
  end

  def payment_notify

    temp_payment = Payment.where(:receipt_data => params[:receipt_data]).first
    if temp_payment and temp_payment.success?
      return render :json => {:error => "invalid receipt data"}, :status => 400
    end

    if params[:access_token].nil?	#无access_token，没有登录，直接购买
      MnAccount.transaction do
        @mn_account = MnAccount.create(:plan_type => params[:plan_type], :last_active_from => MnAccount::ACTIVE_FROM_APPLE,:last_trade_num => MnAccount.rand_trade_num)
        @payment = @mn_account.payments.create(:payment_total_fee => MnAccount::TOTAL_FEE[params[:plan_type].to_i], :plan_type => params[:plan_type])
    
      end
    else	#有access_token
      @mn_account = MnAccount.where(:access_token => params[:access_token]).first
      if @mn_account.user.nil?	#有access_token,无用户绑定，继续购买
    
          MnAccount.transaction do
            @mn_account.update_attributes(:last_trade_num => MnAccount.rand_trade_num)
            @payment = @mn_account.payments.create(:payment_total_fee => MnAccount::TOTAL_FEE[params[:plan_type].to_i], :plan_type => params[:plan_type])
          end
      else	#有access_token，且有用户绑定，充值
        @current_user = @mn_account.user
        MnAccount.transaction do
            @mn_account.update_attributes(:last_trade_num => MnAccount.rand_trade_num)
            init_accounts(params[:plan_type].to_i, MnAccount::ACTIVE_FROM_APPLE)
            init_payment_with(@current_account, params[:plan_type].to_i)
        end
      end
    end
    @payment.set_waiting_from_apple_store_receipt(params[:receipt_data])
    if current_device == MnAccount::DEVICE_IPHONE
      Resque.enqueue(Jobs::VerifyApplePaymentJob, params[:receipt_data], params[:plan_type])
    end
    @mn_account.try(:reload)
    @mn_account.check_access_token
    return render :json => create_json_result(@mn_account)
  end

  def sign_in
    if params[:trade_num]
      @mn_account = MnAccount.where(:last_trade_num => params[:trade_num]).first
      return render :json => {:error => "您的订单号码不正确"}, :status => 401 if @mn_account.nil?
      @mn_account.check_access_token
      @mn_account.check_access_token(@mn_account.access_token)
      update_user_session @mn_account.user if @mn_account.present? && @mn_account.user.present?
      return render :json => create_json_result(@mn_account)
    else
      if user = User.authenticate(params[:nickname], params[:password])
        @user = user
        update_user_session user
        if @mn_account
          @mn_account = @mn_account.bind_user(@user) unless @mn_account.binded?
          @mn_account.check_access_token
        else
          if user.mn_account.nil?
            user.create_mn_account_gift(current_device,MnAccount::ONE_WEEK_GIFT_TIME,false,nil)
          else
            user.mn_account.check_access_token
          end
        end
        user.reload
        return render :json => create_json_result(@user.mn_account)
      else
        return render :json => {:error => "用户名或密码错误"}, :status => 401
      end
    end


  end

  def sign_out
    update_user_session nil
    return render :json => {:message => "登出成功"}
  end

end
