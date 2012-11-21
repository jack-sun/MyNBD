#encoding: utf-8
class Console::NoticesController < ApplicationController
  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_common_console, :except => [:list]
  
  
  def index
    @common_navs = "notice"
    @notices = Notice.order("id DESC").includes(:staff).page(params[:page])
  end
  
  def list
    init_news_console
    @notice_list_navs = true
    @view_only = true
    @notices = Notice.order("id DESC").includes(:staff).page(params[:page])
  end
  
  def show
    @common_navs = "notice"
  end
  
  def new
    @common_navs = "notice"
    @notice = Notice.new
  end
  
  def create
    @notice = @current_staff.notices.create(params[:notice])
    redirect_to console_notices_url, :notice => "success"
  end
  
  def edit
    @common_navs = "notice"
    @notice = Notice.find(params[:id])
  end
  
  def update
    @notice = Notice.find(params[:id])
    @notice.update_attributes!(params[:notice])
    redirect_to console_notices_url, :notice => "success"
  end
  
  def destroy
    @notice = Notice.find(params[:id])
    @notice.destroy
    redirect_to console_notices_url, :notice => "success"
  end
  
end
