class AppKeyFilter
  def self.filter(controller)
    app_key = controller.params[:app_key]
    if app_key == Settings.iphone_app_key
      controller.current_device = MnAccount::DEVICE_IPHONE
    elsif app_key == Settings.android_app_key
      controller.current_device = MnAccount::DEVICE_ANDROID
    else
      return controller.render :json => {:error => "invalid app key"}
    end
  end
end
