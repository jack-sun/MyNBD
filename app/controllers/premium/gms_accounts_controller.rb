#encoding:utf-8
class Premium::GmsAccountsController < ApplicationController
    include Premium::PremiumUtils
	  layout "mobile_newspaper"
  	before_filter :current_user
  	before_filter :authorize , :except => [:introduce]
    before_filter :authorize_gms_account, :only => [:buy]  	

    def new
      @article_id = params[:article_id]
    end

  	def create
  		@gms_account = @current_user.create_gms_account({:last_active_from => MnAccount::DEVICE_WEB, :plan_type => -1})
      cookies[:gms_access_token] = @current_user.update_access_tokens([:gms_account])[:gms_access_token]
      return redirect_to buy_premium_gms_accounts_path if params[:buy] == 'true'
  		return redirect_to premium_gms_article_path(:id => params[:article_id])
  	end

  	def pay
          @gms_article = GmsArticle.find(params[:gms_article_id])
  	end

    def show
      session[:jumpto] = premium_mobile_newspaper_account_url
      @gms_account = GmsAccount.find(params[:id])
      @current_user = @gms_account.user
    end

    def buy
      return render :template => 'premium/gms_accounts/item_show'
    end

    def buy_confirm
      session[:jumpto] = premium_mobile_newspaper_account_url if session[:jumpto].blank?
      Rails.logger.info("=========session:#{session[:jumpto]}")
      plan_type = params[:plan_type].to_i
      GmsAccount.transaction do
        @payment = init_gms_payments(plan_type)
      end
      options = {}
      options[:out_trade_no] = @payment.out_trade_no
      options[:amount] = @payment.payment_total_fee.to_s
      options[:body] = "Mobile每日经济新闻xxxxx 订单号：#{@payment.out_trade_no}"
      count = I18n.t("service_time.mn_account.type_params[:plan_type]")
      options[:subject] = "购买投资宝股东大会实录#{GmsAccount::PLAN_TYPE[plan_type]} 用户信息：#{@current_user.id} / #{@current_user.nickname}"#订阅股东大会实录服务 套餐#{params[:plan_type]}"
      options[:from] = MnAccount::DEVICE_WEB
      # Rails.logger.info("=========options:#{options}")
      return redirect_to make_url_by_query_string(options,Premium::AlipaysController::GMS_ACCOUNT_NOTIFY)
    end

    def receive_credits_from_ttyj
      credits = @current_user.receive_credits_from_ttyj
      return redirect_to premium_gms_articles_path, :notice => "您已成功领取#{MnAccount::RECEIVE_CREDITS}个每经信用点! 您当前的点数为：#{@current_user.credits}"
    end

    private

    def init_gms_payments(plan_type)
      gms_account = @current_user.gms_account
      
      last_payment = gms_account.payments.last
      if last_payment.nil? or last_payment.success?
        last_payment = gms_account.payments.create(:payment_total_fee => GmsAccount::TOTAL_FEE[plan_type], :user_id => @current_user.id, :plan_type => plan_type,:status => Payment::STATUS_WAITE)
      elsif last_payment.faild?
        last_payment.update_attributes(:payment_total_fee => GmsAccount::TOTAL_FEE[plan_type], :user_id => @current_user.id, :plan_type => plan_type,:status => Payment::STATUS_WAITE)      
      end
      last_payment
    end

    def authorize_gms_account
      if @current_user.gms_account.nil?
        return redirect_to new_premium_gms_accounts_path(:buy => true)#, :notice => "buy_premium_gms_accounts_path"# if @current_user.gms_account.nil?
      end
    end
end
