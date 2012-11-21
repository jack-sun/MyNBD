class Logs::WebsiteLogsController < ApplicationController
  USER_NAME = "nbddog"
  PASSWORD = "fuckbugs9494"
  if Rails.env.production?
    before_filter :authenticate
  end
  
  def index
    @logs = WebsiteLog.order("id DESC").page(params[:page]).per(15)
  end

  def show
    @log = WebsiteLog.find(params[:id])
  end


  private
  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
    end
  end
  
end
