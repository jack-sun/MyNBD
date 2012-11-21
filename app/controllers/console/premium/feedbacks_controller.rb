class Console::Premium::FeedbacksController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_mobile_newspaper_console

  def index
    @feedbacks = Feedback.order("id desc").includes(:user).page(params[:page]).per(10)
    @feedbacks_type = "index"
  end
  
end
