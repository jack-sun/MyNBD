# encoding: utf-8
class RegistrationsController < ApplicationController
  
  layout 'register'
  
  before_filter :authorize, :only => [:activate, :activate_expiry, :resend_activate]
  
  # GET: user sign up
  def new
    @user = User.new
    session[:omniauth] = nil
  end
  
  # POST: user sign up
  def create
    @user = User.new(params[:user])
    
    @user.apply_omniauth(session[:omniauth]) if session[:omniauth].present?
    
    if session[:omniauth].nil?
      #if !simple_captcha_valid?("simple_captcha")
      flash[:captcha_error] = nil
      if !simple_captcha_valid?("simple_captcha")
        flash[:captcha_error] = "验证码错误！"
        return render :action => "new"
      elsif @user.save
        update_user_session @user
        redirect_to step_1_user_url(@user)
      else
        render :action => "new"
      end
    else
      if @user.save
        update_user_session @user
        redirect_to step_1_user_url(@user)
      else
        render :action => "bind_account"
      end
    end
  end

  # GET or POST
  def bind_account
    @user = User.new
    if session[:omniauth]
      @user.nickname = session[:omniauth]["info"]["name"] || session[:omniauth]["info"]["nickname"]
    else
      redirect_to sign_up_url
    end
  end
  
  # GET: activate user
  def activate
    @user = User.find_by_activate_token!(params[:id])
    
    if @user.activate_sent_at < 24.hours.ago
      redirect_to activate_expiry_path
    else
      
      @user.activate
      update_user_session @user
      
      User.online_users[@user.id] = Time.now.to_i
      
      redirect_to step_1_user_url(@user)
      #redirect_to user_path(@user)  
    end
    
  end
  
  # GET: 激活token已过期
  def activate_expiry
    
  end
  
  # POST: 重新发送激活邮件
  def resend_activate
    @current_user.send_activate_user
    
    redirect_to user_sign_up_pending_path
  end

  def reload_captcha
    if !request.xhr?
      return render :text => "nimeide"
    end
  end
  
end
