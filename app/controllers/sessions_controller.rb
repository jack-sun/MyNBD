# encoding: utf-8
class SessionsController < ApplicationController

  layout 'register'
  
  before_filter :current_user, :only => [:destroy]
  
  # GET: user sign in
  def new
    session[:jumpto] = params[:redirect_url] if params[:redirect_url]
    if session[:user_id]
      user = User.where(:id => session[:user_id]).first
      redirect_to user_url(user) if user.present? 
    end
  end
  
  # POST: user sign in
  def create
    if user = User.authenticate(params[:email], params[:password])
      
      update_user_session(user)
      
      if params[:remember_me] == "1"
        cookies.permanent[:CHKIO] = {:value => user.auth_token, :domain => Settings.session_domain}
      else
        cookies[:CHKIO] = {:value => user.auth_token, :domain => Settings.session_domain}
      end
      
      User.online_users[user.id] = Time.now.to_i
      
      if session[:omniauth].present?
        user.bind_omniauth(session[:omniauth])
        session[:omniauth] = nil
      end
      
      # temp comment by vincent, 2013-01-10
      cookies[:gms_access_token] = user.update_access_tokens[:gms_access_token]

      after_sign_in_and_redirect_to(user)
      return
    else
      return redirect_to :back, :alert => "用户名密码不匹配" if params[:come_back] == '1'
      session[:jumpto] = request.env["HTTP_REFERER"] if params[:come_back] == "1" && request.env["HTTP_REFERER"] 
      redirect_to user_sign_in_url, :method => :get, :alert => "用户名密码不匹配"
    end
  end

  def destroy
    User.online_users.delete(@current_user.id) if @current_user
    update_user_session nil
    cookies.delete(:CHKIO, :domain => Settings.session_domain)
    session = nil

    redirect_to weibo_host_url
    #redirect_to :back
  end

end
