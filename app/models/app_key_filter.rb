class AppKeyFilter
  def self.filter(controller)
    app_key = controller.params[:app_key]
    controller.current_device = MnAccount::ACTIVE_FROM_APPLE if app_key == Settings.iphone_app_key
    controller.current_device = MnAccount::ACTIVE_FROM_ANDROID if app_key == Settings.android_app_key
    return controller.render :json => {:error => "invalid app key"} unless controller.current_device.present?
  end
end
