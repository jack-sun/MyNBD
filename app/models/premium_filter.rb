class PremiumFilter
  def self.filter(controller)
    return controller.render :json => {:error => "only premium"}, :status => 403 if controller.current_user.nil?
    return controller.render :json => {:error => "only premium"}, :status => 403 unless controller.current_user.is_valid_premium_user?
  end
end
