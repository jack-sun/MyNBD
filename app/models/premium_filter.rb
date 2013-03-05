#encoding: utf-8
class PremiumFilter
  def self.filter(controller)
    # return controller.render :json => {:error => "您的帐号已在别处登录，请重新登录", :error_type => 1 }, :status => 403 if controller.current_mn_account_by_token.nil?
    # return controller.render :json => {:error => "您的帐号已过期，请续费", :error_type => 2 }, :status => 403 unless controller.current_mn_account_by_token.account_valid?
    return controller.render :json => {:error => "您的帐号已在别处登录，请重新登录"}, :status => 401 if controller.current_mn_account_by_token.nil?
    return controller.render :json => {:error => "您的帐号已过期，请续费"}, :status => 403 unless controller.current_mn_account_by_token.account_valid?

  end
end
