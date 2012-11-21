class MobilesController < ApplicationController
  
  layout "mobile_apps"

  def android
    
  end
  
  def iphone
    return render :text => "iphone"
  end
  
  def ipad
    return render :text => "ipad"
  end

end
