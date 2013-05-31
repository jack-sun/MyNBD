# encoding: utf-8
class Console::WeibosController < ApplicationController
  
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_community_console
  # after_filter :add_weibo_log, :only => [:change_status]
  
  def index
    @weibos = Weibo.exclude_sys.includes(:owner).page(params[:page])
    @weibos_navs = "all"
    
    render :index
  end
  
  def hot_rt
    @weibos = Weibo.hot_rt_weibos(50)#.includes(:owner).page(params[:page])
    @weibos_navs = "hot_rt"
    
    render :index
  end
  
  def hot_comment
    @weibos = Weibo.hot_comment_weibos.includes(:owner).page(params[:page])
    @weibos_navs = "hot_comment"
    
    render :index
  end
  
  def sys_weibos
    @weibos = Weibo.sys.includes(:owner).page(params[:page])
    @weibos_navs = "sys"
    render :index
  end
  
  def banned
    @weibos = Weibo.banned.includes(:owner).page(params[:page])
    @weibos_navs = "banned"
    
    render :index
  end
  
  # delete a weibo
  def destroy
    @weibo = Weibo.where(:id => params[:id]).includes(:owner).first
    
    @weibo.owner.delete_weibo(@weibo) if @current_staff.can_monitor_weibo? and @weibo.present?
    @objects = [@weibo]
  end

  def change_status

    id = params[:id].index(",") ? params[:id].split(",") : params[:id]
    logger.debug "-----------#{id}----------"
    @weibos = Weibo.where(:id => id)
    
    Weibo.transaction do
      @weibos.each do |w|
        if !(w.update_attributes(:status => params[:status])) || !(add_weibo_log(w.id))
          return render :js => "alert('更改失败')"
        end
      end
    end
    @objects = @weibos
    render "console/articles/change_status"
  end

  def delete_weibos
    id = params[:id].split(",")
    @weibos = Weibo.where(:id => id)
    Weibo.transaction do
      @weibos.each do |w|
        w.destroy
      end
    end
    @objects = @weibos
    render "destroy.js"
  end
  
  # ban a weibo
  def ban
    @weibo = Weibo.where(:id => params[:id]).includes(:owner).first

    Weibo.ban_weibo(@weibo.id) if @current_staff.can_monitor_weibo? and @weibo.present?
  end
  
  #un ban a weibo
  def unban
     @weibo = Weibo.where(:id => params[:id]).includes(:owner).first
     
     Weibo.unban_weibo(@weibo.id) if @current_staff.can_monitor_weibo? and @weibo.present?
     
     render :ban
  end
  
  def toggle_content_check_status
    status = Weibo.content_check_needed? ? Weibo::WEIBO_ON : Weibo::WEIBO_OFF
    roll_back_status = Weibo.content_check.value.to_i
    Weibo.set_content_check_status(status)
    add_community_switch_logs(status, roll_back_status)
    
    redirect_to console_community_switch_logs_url
  end

  private

  def add_weibo_log(weibo_id)
    cmd = params[:status] == "2" ? 2 : 0
    WeiboLog.add_weibo_log(weibo_id, @current_staff.id, cmd, request.ip)
  end

  def add_community_switch_logs(status, roll_back_status)
    cmd = status == Weibo::WEIBO_ON ? CommunitySwitchLog::ON : CommunitySwitchLog::OFF
    CommunitySwitchLog.add_community_switch_logs(@current_staff.id, cmd, request.ip, roll_back_status)
  end
  
end
