# encoding: utf-8
class Koubeibang::SessionsController < Koubeibang::KoubeibangBaseController

  before_filter :auth_signed_in

  def create
    unless simple_captcha_valid?("simple_captcha")
      flash[:captcha_error] = "验证码错误！"
      render :new and return
    end
    if kbb_account = authenticate(params[:name], params[:password], params[:company_name])
      session[:kbb_account_id] = kbb_account.id
      redirect_to edit_koubeibang_account_url(session[:kbb_account_id]) and return
    else
      flash.now.alert = "用户名密码或机构名称不正确, 请重新输入"
      render :new and return
    end
  end

  private

  def authenticate(name, password, company_name)
    if kbb_account = KoubeibangAccount.where(:name => name, :company_name => company_name).first
      kbb_account = KoubeibangAccount.where(:name => name, 
                                            :company_name => company_name, 
                                            :hashed_password => KoubeibangAccount.encrypt_password(password, kbb_account.salt)).first
      kbb_account
    end
  end

  def auth_signed_in
    redirect_to edit_koubeibang_account_url(session[:kbb_account_id]) if signed_in?
  end

end
