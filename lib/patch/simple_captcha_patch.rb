module SimpleCaptcha #:nodoc
  module ViewHelper #:nodoc
    def simple_captcha_field(options={})
      if options[:object]
        text_field(options[:object], :captcha, :value => '', :autocomplete => 'off') +
        hidden_field(options[:object], :captcha_key, {:value => options[:field_value]})
      else
        text_field_tag(:captcha, nil, :autocomplete => 'off')
      end
    end

    def show_simple_captcha(options={})
      key = simple_captcha_key(options[:object], options[:session_key])
      options[:field_value] = set_simple_captcha_data(key, options)
      
      defaults = {
         :image => simple_captcha_image(key, options),
         :label => options[:label] || I18n.t('simple_captcha.label'),
         :field => simple_captcha_field(options),
         :other_options => options
         }
         
      render :partial => 'simple_captcha/simple_captcha', :locals => { :simple_captcha_options => defaults }
    end

    def simple_captcha_key(key_name = nil, session_key = "captcha")
      if key_name.nil?
        if session_key == "captcha"
          session[session_key] ||= SimpleCaptcha::Utils.generate_key(session[:id].to_s, 'captcha')
        else
          session[session_key] = SimpleCaptcha::Utils.generate_key(session[:id].to_s, session_key)
        end
      else
        SimpleCaptcha::Utils.generate_key(session[:id].to_s, key_name)
      end
    end 
  end
end
module SimpleCaptcha #:nodoc 
  module ControllerHelpers #:nodoc
    # This method is to validate the simple captcha in controller.
    # It means when the captcha is controller based i.e. :object has not been passed to the method show_simple_captcha.
    #
    # *Example*
    #
    # If you want to save an object say @user only if the captcha is validated then do like this in action...
    #
    #  if simple_captcha_valid?
    #   @user.save
    #  else
    #   flash[:notice] = "captcha did not match"
    #   redirect_to :action => "myaction"
    #  end
    def simple_captcha_valid?(key = nil)
      return true if Rails.env.test?
      
      if params[:captcha]
        data = SimpleCaptcha::Utils::simple_captcha_value(session[key || "captcha"])
        result = data == params[:captcha].delete(" ").upcase
        SimpleCaptcha::Utils::simple_captcha_passed!(session[key || "captcha"]) if result
        return result
      else
        return false
      end
    end
  end
end
