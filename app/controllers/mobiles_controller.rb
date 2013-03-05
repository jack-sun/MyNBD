class MobilesController < ApplicationController
  
  layout "mobile_apps"

  def android
    @current = 'android'
  end
  
  def iphone
    @current = 'iphone'
  end
  
  def ipad
    return render :text => "ipad"
  end

  def upgrade
  	browser = users_browser
  	if browser.index('i') == 0
  		return redirect_to "https://itunes.apple.com/us/app/mei-ri-jing-ji-xin-wen-guan/id591578767?ls=1&mt=8"
  	else
  		return redirect_to "http://www.nbd.cn/mobiles/android"
  	end
  end

  private
  def users_browser
	user_agent =  request.env['HTTP_USER_AGENT'].downcase 
	@users_browser ||= begin
	  if user_agent.index('msie') && !user_agent.index('opera') && !user_agent.index('webtv')
	                'ie'+user_agent[user_agent.index('msie')+5].chr
	    elsif user_agent.index('gecko/')
	        'gecko'
	    elsif user_agent.index('opera')
	        'opera'
	    elsif user_agent.index('konqueror')
	        'konqueror'
	    elsif user_agent.index('ipod')
	        'ipod'
	    elsif user_agent.index('ipad')
	        'ipad'
	    elsif user_agent.index('iphone')
	        'iphone'
	    elsif user_agent.index('chrome/')
	        'chrome'
	    elsif user_agent.index('applewebkit/')
	        'safari'
	    elsif user_agent.index('googlebot/')
	        'googlebot'
	    elsif user_agent.index('msnbot')
	        'msnbot'
	    elsif user_agent.index('yahoo! slurp')
	        'yahoobot'
	    #Everything thinks it's mozilla, so this goes last
	    elsif user_agent.index('mozilla/')
	        'gecko'
	    else
	        'unknown'
	    end
	    end

	    return @users_browser
	end
end

