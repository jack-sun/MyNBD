class AccessTokenFilter
  def self.filter(controller)
    return controller.render :json => {:error => "invalid access token"}, :status => 403 if controller.current_mn_account_by_token.nil?
    return controller.render :json => {:error => "invalid access token"}, :status => 403 unless controller.current_mn_account_by_token.check_access_token(controller.params[:access_token])
  end
end
