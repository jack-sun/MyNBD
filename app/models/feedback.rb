#encoding:utf-8
class Feedback < ActiveRecord::Base

  belongs_to :user
  validates_format_of :phone_no, :with => /^\d{11}$/, :message => "手机号码格式错误"
  validates_presence_of :email, :message => "邮箱地址不能为空"
  validates_presence_of :body, :message => "内容不能为空"
  validates_format_of :email, :with => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i,
    :message => '邮箱格式不正确', :if => Proc.new{|u| !u.email.blank?}
  
end
