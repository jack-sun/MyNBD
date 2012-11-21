# encoding: utf-8
class PasswordResetsController < ApplicationController
  
  # All about password resets
  
  layout 'register'  
  
  # GET: reset password request
  def new
    
  end
  
  # POST: reset password request and sent a email 
  def create
    user = User.where(:email => params[:email]).first  
    user.send_password_reset if user #and user.is_active?
    redirect_to password_reset_email_sent_url + "?email=#{params[:email]}"
  end
  
  # GET: update password
  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end
  
  # PUT: update password
  def update
    @user = User.find_by_password_reset_token!(params[:id])  
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_url, :method => :get, :alert => "重置密码已过期，请重新申请重置密码"
    elsif @user.update_attributes(params[:user])  
      redirect_to user_sign_in_url, :method => :get, :notice => "密码重置成功，请用新密码登录"
    else
      render :edit  
    end
  end
  
  # GET: password_reset_email_sent
  def email_sent
    
  end
  
  
end
