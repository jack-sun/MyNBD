class Console::WeiboLogsController < ApplicationController

  layout 'console'
  
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_community_console

  def index
    @weibo_logs = WeiboLog.where("weibo_id = ?", params[:weibo_id]).order("id desc").page(params[:page]).per(30)
  end

end
