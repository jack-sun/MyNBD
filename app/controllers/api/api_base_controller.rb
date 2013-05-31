#encoding:utf-8
class Api::ApiBaseController < ApplicationController
  skip_filter :current_user
  def current_mn_account_by_token
    @mn_account ||= (MnAccount.where(:access_token => params[:access_token]).first if params[:access_token].present?)
  end

  def authorize_mn_account
    return render :json => {:error => "你的帐号已在别处登录，请重新登录"}, :status => 401 unless @mn_account.present?
  end

  def app_key_filter
    app_key = params[:app_key]
    self.current_device = MnAccount::ACTIVE_FROM_APPLE if app_key == Settings.iphone_app_key
    self.current_device = MnAccount::ACTIVE_FROM_ANDROID if app_key == Settings.android_app_key
    return render :json => {:error => "invalid app key"} unless self.current_device.present?
  end  
end
