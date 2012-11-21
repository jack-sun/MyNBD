#encoding:utf-8
class Console::SessionsController < ApplicationController
  layout "console"
  USER_NAME = "savesparta"
  PASSWORD = "nbdanti9105"

  before_filter :authenticate, :only => [:new]
  
  def new
    if session[:staff_id].present?
      redirect_to published_console_articles_path
    else
      render(:layout=>'application')
    end
    
  end
  
  def create
    if staff = Staff.authenticate(params[:name], params[:password])
      update_staff_session(staff)
      
      if session[:jumpto].present?
        redirect_to session[:jumpto].to_s
        session[:jumpto] = nil
      else
        redirect_to published_console_articles_path
      end
    else
      redirect_to console_sign_in_path, :method => :get, :alert => "用户名密码不正确, 请重新输入"
    end
  end
  
  def destroy
    update_staff_session nil
    redirect_to :back
  end
  
  private
  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
    end
  end
end
