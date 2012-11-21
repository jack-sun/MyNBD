#encoding:utf-8
class Api::UsersController < ApplicationController
  skip_filter :current_user
  before_filter :current_user_by_token, :only => [:destroy, :account, :payment_notify]
  before_filter :authorize, :only => [:account, :payment_notify]
  before_filter AccessTokenFilter, :only => [:account, :payment_notify]
  before_filter AppKeyFilter
  skip_before_filter :verify_authenticity_token, :only => [:payment_notify]
  attr_accessor :current_device

  include Premium::PremiumUtils

  def create
    @user = User.new(:nickname => params[:nickname], :email => params[:email], :password => params[:password], :password_confirmation => params[:password_confirmation])    

    if @user.save
      update_user_session @user
      @user.create_mn_account_gift(MnAccount::SERVICE_TYPE_APPLE_GIFT)
      return render :json => {
                                :access_token => @user.valid_access_token,
                                :user_id => @user.id,
                                :nickname => @user.nickname,
                                :email => @user.email,
                                :touzibao_account => {
                                                        :expiry_at => @user.mn_service_end_at * 1000,
                                                        :alert => {
                                                        :today => Time.now.to_i * 1000,
                                                        :count_down_days_alert => MnAccount::COUNT_DOWN_DAYS_ALERT
                                                        },
                                                        :plan_type => @user.mn_account.try(:plan_type),
                                                        :is_valid => @user.is_valid_premium_user?,
                                                        :last_activated_from => @user.mn_activated_from,
                                                        :last_payment_at => @user.mn_last_payed_at * 1000
                                                     }
                             }
    else
      error = {}
      @user.errors.each do |k, v|
        error[k] = v.first
      end
      return render :json => {:error => error}, :status => 401
    end
  end

  def account
    @user = @current_user
    return render :json => {
      :access_token => @user.valid_access_token,
      :user_id => @user.id,
      :nickname => @user.nickname,
      :email => @user.email,
      :touzibao_account => {
        :expiry_at => @user.mn_service_end_at * 1000,
        :is_valid => @user.is_valid_premium_user?,
      :alert => {
      :today => Time.now.to_i * 1000,
      :count_down_days_alert => MnAccount::COUNT_DOWN_DAYS_ALERT
      },
        :plan_type => @user.mn_account.try(:plan_type),
        :last_activated_from => @user.mn_activated_from,
        :last_payment_at => @user.mn_last_payed_at * 1000
      }
    }
  end

  def payment_notify
    #apple_response = verify_apple_puchase(params[:receipt_data])
    temp_payment = Payment.where(:receipt_data => params[:receipt_data]).first
    if temp_payment and temp_payment.success?
      return render :json => {:error => "invalid receipt data"}, :status => 400
    end
    MnAccount.transaction do
      init_accounts(params[:plan_type].to_i, MnAccount::ACTIVE_FROM_APPLE)
      init_payment_with(@current_account, params[:plan_type].to_i)
      @payment.set_waiting_from_apple_store_receipt(params[:receipt_data])
    end
    if current_device == MnAccount::DEVICE_IPHONE
      Resque.enqueue(Jobs::VerifyApplePaymentJob, params[:receipt_data], params[:plan_type])
    end
    @current_user.mn_account.try(:reload)

    return render :json => {
      :access_token => @current_user.valid_access_token,
      :user_id => @current_user.id,
      :nickname => @current_user.nickname,
      :email => @current_user.email,
      :touzibao_account => {
      :expiry_at => @current_user.mn_service_end_at * 1000,
      :is_valid => @current_user.is_valid_premium_user?,
      :alert => {
      :today => Time.now.to_i * 1000,
      :count_down_days_alert => MnAccount::COUNT_DOWN_DAYS_ALERT
      },
      :plan_type => @current_user.mn_account.try(:plan_type),
      :last_activated_from => @current_user.mn_activated_from,
      :last_payment_at => @current_user.mn_last_payed_at * 1000
    }
    }
  end

  def sign_in
      #if user = User.authenticate(user_name, password)
    if user = User.authenticate(params[:nickname], params[:password])
      @user = user
      update_user_session user
      if user.mn_account.nil?
        user.create_mn_account_gift(MnAccount::SERVICE_TYPE_APPLE_GIFT)
        user.reload
      end
      return render :json => {
        :access_token => @user.valid_access_token,
        :user_id => @user.id,
        :nickname => @user.nickname,
        :email => @user.email,
        :touzibao_account => {
          :expiry_at => @user.mn_service_end_at * 1000,
          :alert => {
          :today => Time.now.to_i * 1000,
          :count_down_days_alert => MnAccount::COUNT_DOWN_DAYS_ALERT
          },
          :is_valid => @user.is_valid_premium_user?,
          :plan_type => @user.mn_account.try(:plan_type),
          :last_activated_from => @user.mn_activated_from,
          :last_payment_at => @user.mn_last_payed_at * 1000
        }
      }
    else
      return render :json => {}, :status => 401
    end
  end

  def sign_out
    update_user_session nil
    return render :json => {:message => "登出成功"}
  end
end
