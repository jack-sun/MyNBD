#encoding:utf-8
class Premium::FeedbacksController < ApplicationController
  before_filter :current_user
  # temp solution for touzibao's sign_in by zhou
  before_filter FlashTouzibaoFilter, :only => [:new]
  before_filter :authorize
  before_filter :current_mn_account, :except => [:alert]

  layout 'touzibao'

  def new
    @feedback = Feedback.new
    @feedback.user_id = @current_user.id
    @feedback.phone_no = @current_mn_account.phone_no
    @feedback.email = @current_user.email
  end

  def create
    @feedback = Feedback.new(params[:feedback])
    flash[:captcha_error] = nil
    if !simple_captcha_valid?("simple_captcha")
      flash[:captcha_error] = "验证码错误！"
      return render :action => "new"
    end
    if @feedback.save
      return redirect_to success_premium_feedbacks_url
    else
      return render :new
    end
  end

  def alert
    
  end

  def success
    
  end

  private
  def current_mn_account
    @current_mn_account = @current_user.mn_account
    if !@current_mn_account
      return redirect_to alert_premium_feedbacks_url
    end
  end
  
end
