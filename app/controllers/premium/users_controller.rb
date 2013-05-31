# encoding: utf-8
class Premium::UsersController < ApplicationController
  
  layout 'touzibao'
  
  #before_filter :authorize #, :only => [:follow, :unfollow, :check_status, :atme, :atme_comments, :comments_to_me, :step_1, :step_2, :settings, :chanage_password, :show, :profile]
  before_filter :authorize, :except => [:check_status]
  
  
  def profile
    @hot_topics = Topic.hot_topics(5)
    @interviewee = User.where(:nickname => params[:id]).first
    @is_same_user = @interviewee.is_same_user?(@current_user)
    @weibos = @interviewee.weibos.includes(:owner).page(params[:page])
  end
  
  def edit
    @user = User.where(:nickname => params[:id]).first
  end
  
  def update
    @user = User.where(:nickname => params[:id]).first
    
    if @user.update_attributes(params[:user])
      redirect_to(@user, :notice => "User #{@user.nickname} was updated done.")
      return
    else
      redirect_to(:action => "edit")
      return
    end
  end
  
  
  #_GET_: show followers of current interviewee
  def followers
    @hot_topics = Topic.hot_topics(5)
    @interviewee = User.where(:nickname => params[:id]).first
    @is_same_user = @interviewee.is_same_user?(@current_user)
    
    @followers = @interviewee.followers
    @current_user.refresh_notifications("new_followers_count")
  end
  
  #_GET_: show followings of current interviewee
  def followings
    @hot_topics = Topic.hot_topics(5)
    @interviewee = User.where(:nickname => params[:id]).first
    @is_same_user = @interviewee.is_same_user?(@current_user)
    
    @followings = @interviewee.followings
  end
  
  def stocks
    @interviewee = User.where(:nickname => params[:id]).first
    @portfolios = @interviewee.portfolios
  end
  
  # 我发出的评论
  def comments
    @hot_topics = Topic.hot_topics(5)
    @comments = @current_user.comments.order("id desc").includes(:weibo => :owner).page(params[:page])
  end
  
  # 我收到的评论：别人对我的微博进行的评论
  def comments_to_me
    @hot_topics = Topic.hot_topics(5)
    @comments = @current_user.comment_logs.includes(:comment => [:weibo, :parent, {:owner => :image}]).order("created_at DESC").page(params[:page])#.map(&:target)
    @current_user.refresh_notifications(:new_comments_count)
  end
  
  #_POST_: follow user
  def follow
    @interviewee = User.where(:nickname => params[:id]).first
    @current_user.follow(@interviewee)
    
    redirect_to profile_user_path(@interviewee)
  end
  
  #_POST_: unfollow user
  def unfollow
    @interviewee = User.where(:nickname => params[:id]).first
    @current_user.unfollow(@interviewee)
    
    redirect_to profile_user_path(@interviewee)
  end
  
  # @提到我的所有微博  
  def atme
    @hot_topics = Topic.hot_topics(5)
    @weibos = @current_user.mentions.weibos.includes(:target => :owner).order("created_at DESC").page(params[:page])#.map(&:target)
    @current_user.refresh_notifications("new_atme_weibos_count")
  end
  
  # @提到我的所有评论
  def atme_comments
    @hot_topics = Topic.hot_topics(5)
    @comments = @current_user.mentions.comments.includes(:target => [{:weibo => :owner}, :owner]).order("created_at DESC").page(params[:page])#.map(&:target)
    @current_user.refresh_notifications("new_atme_comments_count")
  end
  
  #TODO
  def favs
    
  end
  
  def n
    @interviewee = User.where(:nickname => params[:nickname]).first
    if @interviewee.nil?
      redirect_to community_search_url(:q => params[:nickname], :type => "user")
      return
    end
    
    if request.xhr?
    else
      if @interviewee.is_same_user?(@current_user)
        @weibos = @interviewee.weibos_following.page(params[:page])
        @current_user.refresh_notifications("new_weibo_ids")
        @hot_topics = Topic.hot_topics(5)
        render :show
      else
        @weibos = @interviewee.weibos.page(params[:page])
        @hot_topics = Topic.hot_topics(5)
        render :profile
        return
      end
    end
  end
  
  # 更新用户基本信息, GET / POST
  def settings
    @user = @current_user
    
    if request.get?
    else
      if params[:user][:nickname].blank?
        @user.errors[:nickname] = "昵称不能为空"
        return
      end
      
      if params[:user][:nickname] != @user.nickname and User.existed?(params[:user][:nickname])
        @user.errors[:nickname] = "昵称 #{params[:user][:nickname]} 已被占用"
        return
      end
      
      if @user.update_attributes(params[:user])
        redirect_to settings_user_url :notice =>  "更改已保存"
      else
        Rails.logger.debug "#################{@user.errors.inspect}"
        render :settings
      end
    end
  end
  
  
  # 更改用户登录密码
  def change_password
    @user = @current_user
    
    if request.get?

    else
      old_password = params[:user].delete(:old_password)
      if old_password.blank?
        @user.errors[:old_password] = "请输入正确的密码"
        return
      end
      
      if User.authenticate(@user.email, old_password)
        new_password = params[:user][:password]
        if new_password.blank?
          @user.errors[:password] = "密码不能为空"
          render :change_password
          return
        end
        
        if @user.update_attributes(params[:user])
          redirect_to premium_mobile_newspaper_account_url, :notice => "密码更改成功"  
        else
          render :change_password
        end
      else
        @user.errors[:old_password] = "密码不匹配，请重新输入旧密码"
        render :change_password
      end
    end
  end

  # 更改用户登录密码
  def change_profile
    @user = @current_user
    
    if request.get?

    else
      if params[:user][:nickname].blank?
        @user.errors[:nickname] = "昵称不能为空"
        return
      end
      
      if params[:user][:nickname] != @user.nickname and User.existed?(params[:user][:nickname])
        @user.errors[:nickname] = "昵称 #{params[:user][:nickname]} 已被占用"
        return
      end
      
      if @user.update_attributes(params[:user])
        redirect_to premium_mobile_newspaper_account_url, :notice =>  "更改已保存"
      else
        Rails.logger.debug "#################{@user.errors.inspect}"
        render :change_profile
      end   
    end
  end  
  
  def weibo_accounts
    @accounts = @current_user.authentications
  end
  
  
end
