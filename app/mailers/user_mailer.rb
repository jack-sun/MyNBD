# encoding: utf-8
class UserMailer < ActionMailer::Base
  default :from => "info@nbd.com.cn"
  
  def welcome_email(user)
    @user = user
    @url  = root_url
    mail(:to => user.email,
         :subject => "Welcome to My Awesome Site")
  end
  
  def password_reset(user)
    @user = user
    mail(:to => user.email, :subject => "密码重置")
  end
  
  def activate_user(user)
    @user = user
    mail(:to => user.email, :subject => "激活用户")
  end
  
end
