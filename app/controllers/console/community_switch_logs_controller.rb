# encoding: utf-8
class Console::CommunitySwitchLogsController < ApplicationController

  layout 'console'

  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_common_console
  #before_filter :is_current_staff_xupeng?

  def index
    @community_switch_logs = CommunitySwitchLog.where("1 = 1").order("id desc").page(params[:page]).per(30)
    @common_navs = "community_switch_log_index"
  end

  private

  def is_current_staff_xupeng?
    return redirect_to stats_console_articles_url, :alert => "唉，你的权限不够啊！" unless staff_name == Settings.xupeng_name
  end
  
end
