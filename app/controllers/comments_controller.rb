class CommentsController < ApplicationController
  before_filter :authorize, :only => [:create, :destroy, :ban]

  cache_sweeper Sweepers::CommentSweeper, :only => [:create, :destroy, :ban]
  
  respond_to :html, :xml, :json
  
  def index
    @weibo = Weibo.find(params[:weibo_id])    
    comments = @weibo.is_ori_weibo? ? @weibo.all_comments : @weibo.comments
    @comments = comments.includes(:owner).order("created_at desc").page(params[:page]).per(5)
  end
  
  def show
    
  end
  
  def new
    
  end
  
  def create
    @weibo = Weibo.find(params[:weibo_id])
    
    # record weibo remote ip, Add by Vincent, 2011-11-29
    params[:comment][:remote_ip] = request.remote_ip if params[:comment].present? and request.remote_ip.present?
    params[:comment][:status] = Comment.content_check_needed? ? Comment::PENDING : Comment::PUBLISHED
    
    @comment = @current_user.comment_to_weibo(@weibo, params[:comment])
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    @current_user.delete_comment(@comment)
  end
  
  def ban
    @comment = Weibo.find(params[:id])
    Comment.ban_comment(@comment.id) if @current_user.is_supper_user?
  end
  
end
