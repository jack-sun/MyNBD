#encoding:utf-8
class Premium::GmsAccountsController < ApplicationController
    include Premium::PremiumUtils
	  layout "touzibao"
  	before_filter :current_user
  	before_filter :authorize , :except => [:introduce, :alipay_test_buy, :alipay_test_pay, :alipay_test_return, :alipay_test_notify]
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


      @payment = init_payment_with(@current_user.gms_account, plan_type, MnAccount::DEVICE_WEB, MnAccount::ACTIVE_FROM_ALIPAY)
      # options = {}
      # options[:out_trade_no] = @payment.out_trade_no
      # options[:amount] = @payment.payment_total_fee.to_s
      # options[:body] = "Mobile每日经济新闻xxxxx 订单号：#{@payment.out_trade_no}"
      # count = I18n.t("service_time.mn_account.type_params[:plan_type]")
      # options[:subject] = "购买投资宝股东大会实录#{GmsAccount::PLAN_TYPE[plan_type]} 用户信息：#{@current_user.id} / #{@current_user.nickname}"#订阅股东大会实录服务 套餐#{params[:plan_type]}"
      # options[:from] = MnAccount::DEVICE_WEB
      # Rails.logger.info("=========options:#{options}")
      return redirect_to make_url_by_query_string(@payment)
    end

    def receive_credits_from_ttyj
      credits = @current_user.receive_credits_from_ttyj
      return redirect_to premium_gms_articles_path, :notice => "您已成功领取#{MnAccount::RECEIVE_CREDITS}个每经信用点! 您当前的点数为：#{@current_user.credits}"
    end

    def authorize_gms_account
      if @current_user.gms_account.nil?
        return redirect_to new_premium_gms_accounts_path(:buy => true)#, :notice => "buy_premium_gms_accounts_path"# if @current_user.gms_account.nil?
      end
    end

end
