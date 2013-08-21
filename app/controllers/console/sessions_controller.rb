#encoding:utf-8
class Console::SessionsController < ApplicationController
  layout "console"
  USER_NAME = "savesparta"
  PASSWORD = "nbdanti9105"

  before_filter :authenticate
  
  def new
    if session[:staff_id].present?
      redirect_to published_console_articles_path
    else
      render(:layout=>'application')
    end
    
  end
  
  def create
    unless Rails.env.development?
      if !simple_captcha_valid?("simple_captcha")
          flash[:captcha_error] = "验证码错误！"
          return render :action => 'new',:layout => 'application'
      end
    end
    if staff = Staff.authenticate(params[:name], params[:password])
      update_staff_session(staff)
      
      if session[:jumpto].present?
        redirect_to session[:jumpto].to_s
        session[:jumpto] = nil
      else
        redirect_to redirect_to_url staff
      end
    else
      redirect_to console_sign_in_path, :method => :get, :alert => "用户名密码不正确, 请重新输入"
    end
  end
  
  def destroy
    session[:jumpto] = nil
    update_staff_session nil
    # redirect_to :back
    redirect_to :console_sign_in
  end
  
  private

  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
    end
  end

  def redirect_to_url staff
    if staff.authority_of_news?
      published_console_articles_url
    elsif staff.authority_of_community?
      console_weibos_url
    elsif staff.authority_of_common?
      stats_console_articles_url
    elsif staff.authority_of_mobile_news?
      console_premium_mobile_newspaper_accounts_url
    elsif staff.authority_of_statistics?
      statistics_index_console_staffs_url
    end
  end
end
