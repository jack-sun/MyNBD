class AuthenticationsController < ApplicationController
  
  before_filter :authorize, :only => [:destroy]
  def index
    @authentications = @current_user.authentications if @current_user  
  end
  
  def create
    omniauth = request.env["omniauth.auth"]  
    logger.debug "--------------------------------------omniauth"
    logger.debug "omniauth: #{omniauth.inspect}"
    authentication = Authentication.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first
    if authentication  
      user = authentication.user
      
      update_user_session(user)
      User.online_users[user.id] = Time.now.to_i
      
      # 2012 - 09 - 18 JasonTai
      # forbid redirect_to qq_connect after sign
      #after_sign_in_and_redirect_to(user, true)
      after_sign_in_and_redirect_to(user, false)
      return
    elsif @current_user
      @current_user.authentications.find_or_create_by_provider_and_uid(:provider => omniauth['provider'], :uid => omniauth['uid'])  
      # 2012 - 09 - 18 JasonTai
      # forbid redirect_to qq_connect after sign
      #after_sign_in_and_redirect_to(@current_user, true)    
      after_sign_in_and_redirect_to(@current_user, false)    
      return
    else
      session[:omniauth] = omniauth.except('extra')

      redirect_to bind_account_url, :method => :get
      return
      #      user = User.new  
      #      user.authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])  
      #      if user.save
      #        flash[:notice] = "Signed in successfully."  
      #        sign_in_and_redirect(:user, user)  
      #      else  
      #        session[:omniauth] = omniauth.except('extra')  
      #        redirect_to new_user_registration_url  
      #      end  
    end
  end

  def destroy
    account = Authentication.find(params[:id])
    account.destroy
    render :js => "$('div##{account.provider}').slideUp()"
  end
  
end
