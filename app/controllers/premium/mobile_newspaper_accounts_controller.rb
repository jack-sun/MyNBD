#encoding: utf-8
class Premium::MobileNewspaperAccountsController < ApplicationController
  layout "touzibao", :except => [:new_mobile, :wap_plan_list, :failure]

  include Premium::PremiumUtils
  before_filter :current_user, :except => [:wap_plan_list]
  # temp solution for touzibao's sign_in by zhou
  before_filter FlashTouzibaoFilter, :only => [:new, :home_page, :touzikuaixun, :tiantianyingjia, :help]
  # before_filter AppKeyFilter, :only => [:wap_plan_list]
  before_filter :authorize , :except => [:introduce, :wap_plan_list, :home_page, :touzikuaixun, :tiantianyingjia, :help]
  before_filter :current_mn_account_by_token, :only => [:new_mobile, :wap_plan_list]
  before_filter :vaild_phone_no, :only => [:subscribe, :activate]
  before_filter :only => [:wap_pay] { |controller| controller.vaild_phone_no 'wap' }
  # before_filter :only => [:wap_plan_list] { |controller| controller.authorize_mn_account 'wap' }
  # before_filter :current_user_by_mn_account, :only => [:wap_plan_list]
  before_filter :authorize_mn_account, :only => [:wap_plan_list]

  def subscribe   
    init_accounts(params[:plan_type], MnAccount::ACTIVE_FROM_ALIPAY)
    return render :new unless @current_account.errors.blank?
    @payment = init_payment_with(@current_account, params[:plan_type].to_i, MnAccount::DEVICE_WEB, MnAccount::ACTIVE_FROM_ALIPAY)
    return redirect_to make_url_by_query_string(@payment)
  end

  def activate
    @current_account = @current_user.mn_account
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
    init_payment_with(@current_account, @service_card.card_type, MnAccount::DEVICE_WEB, MnAccount::ACTIVE_FROM_CARD)
    @payment.set_success_from_card(@service_card)

    return redirect_to success_premium_mobile_newspaper_account_url
  end

  def show
    session[:jumpto] = premium_mobile_newspaper_account_url
    @account = @current_user.mn_account
    @gms_account = @current_user.gms_account
  end

  def success
    @account = @current_user.mn_account
    @payment = @current_user.payments.last
  end

  def waiting
  end

  def introduce
    return redirect_to premium_touzibao_home_page_url
  end

  def new
    @current_account = @current_user.mn_account
  end

  def new_mobile
    @current_user = current_user_by_mn_account
  end

  def wap_pay
    init_accounts(params[:plan_type], MnAccount::ACTIVE_FROM_ALIPAY)
    return render :new unless @current_account.errors.blank?
    @payment = init_payment_with(@current_account, params[:plan_type].to_i, params[:payment_device], MnAccount::ACTIVE_FROM_ALIPAY)
    token = get_wap_alipay_token(@payment)
    return render :new unless token
    wap_alipay_url = get_wap_alipay_url(token)
    # Rails.logger.info("===url:#{wap_alipay_url}")
    return redirect_to wap_alipay_url
  end

  def wap_plan_list
    @current_user = current_user_by_mn_account
    @payment_device = get_device_name_by_app_key
    session[:user_id] = @current_user.id
  end


  def home_page
    @current_item = 'index'
    @news_report_articles = Column.find(Column::TOUZIBAO_REPORT_COLUMN).articles.order('pos DESC').limit(5)
    @success_case_articles = Column.find(Column::TOUZIBAO_CASE_COLUMN).articles.order('pos DESC').limit(5)
    @reader_salon_articles = Column.find(Column::TOUZIBAO_SALON_COLUMN).articles.order('pos DESC').limit(5)
  end

  def tiantianyingjia
    @current_item = 'tiantianyingjia'
  end

  def touzikuaixun
    @current_item = 'touzikuaixun'
    article_columns = Column.find(Column::MOBILE_NEWS_COLUMN).articles_columns.order("pos desc")
    .where(:status => Article::PUBLISHED).offset(1).first
    @article = article_columns.try(:article)        
  end

  protected

  def vaild_phone_no(from="web")
    vaild_phone_fail = (params[:mobile_no] =~ /^\d{11}$/).nil?
    if vaild_phone_fail
      @current_account = @current_user.mn_account
      @phone_no_error = true
      params[:type] = "1" if params[:action] == 'activate'
      if from == "wap"
        flash[:notice] = "手机号码格式错误"
        @payment_device = params[:payment_device]
        return render :wap_plan_list, :layout => false
      else
        return render :new
      end
    end
  end

  def get_device_name_by_app_key
    if params[:app_key] == Settings.iphone_app_key
      MnAccount::DEVICE_NAMES[MnAccount::ACTIVE_FROM_APPLE]
    elsif params[:app_key] == Settings.android_app_key
      MnAccount::DEVICE_NAMES[MnAccount::ACTIVE_FROM_ANDROID]
    end
  end

end
