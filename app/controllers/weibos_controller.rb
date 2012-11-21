# encoding: utf-8
class WeibosController < ApplicationController
  
  layout 'weibo'
  
  before_filter :authorize #, :only => [:create, :destroy, :rt, :fetch_new, :ban, :unban]
  before_filter :content_review, :only => [:create, :rt]
  
  def index
    
  end

  def fetch_new
    @weibos = @current_user.new_unread_weibo
    @interviewee = @current_user
    @current_user.refresh_notifications("new_weibo_ids")
  end
  
  def create
    remote_ip = request.remote_ip
    @from = (params[:from] || "").strip
    @weibo = @current_user.create_plain_text_weibo(params[:content], remote_ip, Weibo.content_check_needed?)
  end
  
  def destroy
    @weibo = Weibo.find(params[:id])
    @current_user.delete_weibo(@weibo)
  end
  
  def rt
    if request.get?
      @weibo = Weibo.find(params[:id])
      @new_weibo = @weibo.rt_weibos.new
    else
      @weibo = Weibo.find(params[:id])
      
      # record weibo remote ip, Add by Vincent, 2011-11-29
      params[:weibo][:remote_ip] =  request.remote_ip if params[:weibo].present? and request.remote_ip.present?
      params[:weibo][:status] = Weibo.content_check_needed? ? Weibo::PENDING : Weibo::PUBLISHED
      
      @new_weibo = @current_user.rt_weibo(@weibo, params[:weibo])
      
      render :rt_post_done
    end
  end
  
  def show
    @weibo = Weibo.find(params[:id])
    raise ActiveRecord::RecordNotFound if @weibo.blank?
    
    @comments = @weibo.comments.order("created_at DESC").includes(:owner).page(params[:page])
  end
  
  def ban
    @weibo = Weibo.find(params[:id])
    Weibo.ban_weibo(@weibo.id) if @current_user.is_supper_user?
  end

  def update
    @live = Live.find(params[:live_id])
    return text => "false" unless @current_user.is_important_user_of?(@live)
    weibo = Weibo.find(params[:id])
    if params[:talk_type] == "comment"
      live_object = weibo.live_talk
      @live_talk = live_object
    else
      live_object = weibo.live_answer
      @live_talk = live_object.live_talk
    end
    weibo.update_attributes(params[:weibo])
    @live_talk.update_attribute(:updated_at, Time.now)
    @live_talks = Array.wrap(@live_talk)
    @stock_live = @live_talk.live
    @is_compere = true
    render "/lives/fetch_new"
  end
  
#  def unban
#    @weibo = Weibo.find(params[:id])
#    Weibo.unban_weibo(@weibo.id) if @current_user.is_supper_user?
#  end

  private
  
  def content_review
    
  end
  
end
