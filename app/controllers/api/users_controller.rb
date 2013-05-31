#encoding:utf-8
class Api::UsersController < Api::ApiBaseController
  # skip_filter :current_user
  before_filter :current_mn_account_by_token, :only => [:destroy, :account, :create, :sign_in]
  before_filter :authorize_mn_account, :only => [:account]
  # before_filter AppKeyFilter
  before_filter :app_key_filter
  # skip_before_filter :verify_authenticity_token, :only => [:payment_notify]

  attr_accessor :current_device

  include Premium::PremiumUtils

  def create
    user = User.new(:nickname => params[:nickname], 
                    :email => params[:email], 
                    :password => params[:password], 
                    :password_confirmation => params[:password],
                    :phone_no => params[:phone_no])



    # user = User.new(:nickname => params[:nickname], :email => params[:email], :password => params[:password], :password_confirmation => params[:phone_no].blank? ? params[:password_confirmation] : params[:password])    
    gift_period = get_gift_period
    is_receive_sms = false
    last_active_from = current_device
    if user.save
      user.create_mn_account_gift(last_active_from, gift_period, is_receive_sms, params[:phone_no]) if @mn_account.nil? || @mn_account.binded?
      @mn_account = @mn_account.bind_user(user) if @mn_account && !@mn_account.binded?
      user.reload
      update_user_session user
      return render :json => user.mn_account.create_json_result      
      # if @mn_account
      #   if @mn_account.binded?
      #   @user.create_mn_account_gift(last_active_from, gift_period, is_receive_sms, params[:phone_no])
      #   else
      #     @mn_account = @mn_account.bind_user(@user)
      #   end
      # else
      #   @user.create_mn_account_gift(last_active_from, gift_period, is_receive_sms, params[:phone_no])
      # end
      # @user.reload

      # update_user_session @user

      # return render :json => @user.mn_account.create_json_result
    else
      error = {}
      user.errors.each do |k, v|
        error[k] = v
      end
      return render :json => {:error => error}, :status => 401
    end
  end

  def account
    return render :json => @mn_account.create_json_result
  end

  def payment_notify
    payment = Payment.where(:receipt_data => params[:receipt_data]).first
    return render :json => {:error => "invalid receipt data"}, :status => 400 if payment && payment.success?

    MnAccount.transaction do
      @mn_account = init_account_with
      return render :json => {:error => ""} if @mn_account.nil?
      @mn_account.update_attribute(:last_trade_num, MnAccount.rand_trade_num)
      payment = init_payment_with(@mn_account, params[:plan_type].to_i, MnAccount::DEVICE_IPHONE, MnAccount::ACTIVE_FROM_APPLE)
      payment.set_waiting_from_apple_store_receipt(params[:receipt_data])
    end
    # @mn_account = @mn_account.bind_user(MnAccount.find(params[:access_token]))
    # payment = @mn_account.payments.create(:payment_total_fee => MnAccount::TOTAL_FEE[params[:plan_type].to_i], 
    #                                       :plan_type => params[:plan_type].to_i,
    #                                       :user_id => @mn_account.user_id,
    #                                       :status => Payment::STATUS_WAITE, 
    #                                       :payment_device => MnAccount::DEVICE_IPHONE, 
    #                                       :payment_type => MnAccount::ACTIVE_FROM_APPLE)
    @mn_account.check_access_token
    @mn_account.reload
    Resque.enqueue(Jobs::VerifyApplePaymentJob, payment.id)
    return render :json => @mn_account.create_json_result


    # temp_payment = Payment.where(:receipt_data => params[:receipt_data]).first
    # if temp_payment and temp_payment.success?
    #   return render :json => {:error => "invalid receipt data"}, :status => 400
    # end

    # if params[:access_token].nil?	#无access_token，没有登录，直接购买
    #   MnAccount.transaction do
    #     @mn_account = MnAccount.create(:plan_type => params[:plan_type], :last_active_from => MnAccount::ACTIVE_FROM_APPLE,:last_trade_num => MnAccount.rand_trade_num)
    #     @payment = @mn_account.payments.create(:payment_total_fee => MnAccount::TOTAL_FEE[params[:plan_type].to_i], :plan_type => params[:plan_type])
    
    #   end
    # else	#有access_token
    #   @mn_account = MnAccount.where(:access_token => params[:access_token]).first
    #   if @mn_account.user.nil?	#有access_token,无用户绑定，继续购买
    
    #       MnAccount.transaction do
    #         @mn_account.update_attributes(:last_trade_num => MnAccount.rand_trade_num)
    #         @payment = @mn_account.payments.create(:payment_total_fee => MnAccount::TOTAL_FEE[params[:plan_type].to_i], :plan_type => params[:plan_type])
    #       end
    #   else	#有access_token，且有用户绑定，充值
    #     @current_user = @mn_account.user
    #     MnAccount.transaction do
    #         @mn_account.update_attributes(:last_trade_num => MnAccount.rand_trade_num)
    #         init_accounts(params[:plan_type].to_i, MnAccount::ACTIVE_FROM_APPLE)
    #         init_payment_with(@current_account, params[:plan_type].to_i, MnAccount::DEVICE_IPHONE, MnAccount::ACTIVE_FROM_APPLE)
    #     end
    #   end
    # end
    # @payment.set_waiting_from_apple_store_receipt(params[:receipt_data])
    # if current_device == MnAccount::DEVICE_IPHONE
    #   Resque.enqueue(Jobs::VerifyApplePaymentJob, @payment.id)
    # end
    # @mn_account.try(:reload)
    # @mn_account.check_access_token
    # return render :json => @mn_account.create_json_result
  end

  def sign_in
    return sign_in_with_trade_num if params.has_key?(:trade_num)

    return sign_in_with_nickname

    # if params[:trade_num]
    #   @mn_account = MnAccount.where(:last_trade_num => params[:trade_num]).first
    #   return render :json => {:error => "您的订单号码不正确"}, :status => 401 if @mn_account.nil?

    #   @mn_account.check_access_token
    #   @mn_account.check_access_token(@mn_account.access_token)
    #   update_user_session @mn_account.user if @mn_account.present? && @mn_account.user.present?
    #   return render :json => @mn_account.create_json_result
    # else
    #   if user = User.authenticate(params[:nickname], params[:password])
    #     @user = user
    #     update_user_session user
    #     if @mn_account
    #       @mn_account = @mn_account.bind_user(@user) unless @mn_account.binded?
    #       @mn_account.check_access_token
    #     else
    #       if user.mn_account.nil?
    #         user.create_mn_account_gift(current_device,MnAccount::ONE_WEEK_GIFT_TIME,false,nil)
    #       else
    #         user.mn_account.check_access_token
    #       end
    #     end
    #     user.reload
    #     return render :json => @user.mn_account.create_json_result
    #   else
    #     return render :json => {:error => "用户名或密码错误"}, :status => 401
    #   end
    # end


  end

  def sign_out
    update_user_session nil
    return render :json => {:message => "登出成功"}
  end


  private 

  def sign_in_with_trade_num
    trade_num_mn_account = MnAccount.where(:last_trade_num => params[:trade_num]).first
    return render :json => {:error => "您的订单号码不正确"}, :status => 401 if trade_num_mn_account.nil?

    access_token_mn_account =  MnAccount.where(:access_token => params[:access_token]).first if params.has_key?(:access_token)
    @mn_account = access_token_mn_account.bind_user(trade_num_mn_account.user)  if access_token_mn_account && !access_token_mn_account.binded? && trade_num_mn_account.user
    return render :json => {:error => "您的订单已绑定"}, :status => 401 unless @mn_account
    
    @mn_account.check_access_token
    update_user_session @mn_account.user if @mn_account && @mn_account.user
    return render :json => @mn_account.create_json_result
  end

  def sign_in_with_nickname
    user = User.authenticate(params[:nickname], params[:password])
    return render :json => {:error => "用户名或密码错误"}, :status => 401 unless user
    update_user_session user

    @mn_account = @mn_account.bind_user(user)  if @mn_account && !@mn_account.binded?
    user.create_mn_account_gift(current_device, MnAccount::ONE_WEEK_GIFT_TIME, false, nil) if user.any_mn_account?

    user.mn_account.check_access_token
    return render :json => user.mn_account.create_json_result    
  end

  def get_gift_period
    params[:phone_no].blank? ? MnAccount::ONE_WEEK_GIFT_TIME : MnAccount::TWO_WEEK_GIFT_TIME
  end

  def init_account_with
    return MnAccount.where(:access_token => params[:access_token]).first if params.has_key?(:access_token)
    return MnAccount.create(:plan_type => params[:plan_type], 
                            :last_active_from => MnAccount::ACTIVE_FROM_APPLE,
                            :is_receive_sms => false  ) unless params.has_key?(:access_token)
  end
end
