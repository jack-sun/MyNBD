# encoding: utf-8
class Console::TopicsController < ApplicationController
  
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_community_console

  cache_sweeper Sweepers::TopicSweeper, :only => [:create, :update, :destroy, :ban, :unban, :update_layout, :edit_banner, :ban_topics, :change_topic_pos, :del_topics]
  
  # 我的内容 - published
  def published
    @topics = @current_staff.topics.published.includes(:staff).page(params[:page])
    @topics_navs = Article::PUBLISHED
    
    render :show
  end
  
  # 我的内容 - draft
  def draft
    @topics = @current_staff.topics.draft.includes(:staff).page(params[:page])
    @topics_navs = Topic::DRAFT
    
    render :show
  end
  
  # 我的内容 - banned
  def banned
    @topics = @current_staff.topics.banned.includes(:staff).page(params[:page])
    @topics_navs = Topic::BANNDED
    
    render :show
  end
  
  # 所有热门话题
  def index
    @topics = Topic.order("pos, id DESC").includes(:staff).page(params[:page])
    @topics_navs = "hot_topics"
    @sortable = true
    
    render :index
  end
  
  def new
    @topic = Topic.new
    @topic.title = params[:tag]
    @topics_navs = "hot_topics"
  end
  
  def create
    @topic = @current_staff.topics.create(params[:topic])
    
    redirect_to edit_console_topic_path(@topic)
  end
  
  def edit
    @topic = Topic.where(:slug => params[:id]).first
    
    @topics_navs = "hot_topics"
  end
  
  def update
    @topic = Topic.where(:slug => params[:id]).first
    @topic.update_attributes!(params[:topic])
    
    if params[:topic][:status].to_i == Topic::PUBLISHED
      redirect_to published_console_topics_url
    else
      redirect_to draft_console_topics_url
    end
    
  end
  
  def destroy
    @topic = Topic.where(:slug => params[:id]).first
    @topic.destroy
    
    render :js => "window.location.reload();"
  end
  
  # DELETE
  def ban
    @topic = Topic.where(:slug => params[:id]).first
    
    Topic.ban_topic(@topic.id) if @current_staff.can_monitor_topic? and @topic.present?
  end
  
  # DELETE
  def unban
    @topic = Topic.where(:slug => params[:id]).first
    
    Topic.unban_topic(@topic.id) if @current_staff.can_monitor_topic? and @topic.present?
    
    render :ban
  end
  
  #POST
  def update_layout
    topic = Topic.where(:slug => params[:id]).first
    
    topic.layout = params[:layout]
    topic.save!
    
    render :text => "done"
  end
  
  #GET/POST
  def edit_banner
    @topic = Topic.where(:slug => params[:id]).first
    
    if request.get?
      render :layout => "element"
    else
      @topic = Topic.where(:slug => params[:id]).first
      @topic.update_attributes!(params[:topic])
      
      render :text => "<script type='text/javascript'>window.close();</script>";
    end
    
    return
  end

  def hot_tags
    @topics_navs = "hot_tags"
    @tags = Topic.hot_tag.map!{|x| h = Topic.tag_detail(x); h["name"] = x; h;}
  end

  def change_topic_pos
    @moved_topic = Topic.find(params[:id])
    @target_topic = Topic.find(params[:target_id])
    render :text => Topic.change_topic_pos(@moved_topic, @target_topic)
  end

  def ban_topics
    topics = Topic.where(:id =>params[:topic_ids].split(","))
    Topic.transaction do
      topics.each do |topic|
        topic.status = 0
        topic.save!
      end
      return render :text => "sueccess"
    end
    return render :text => "faild"
  end

  def del_topics
    topics = Topic.where(:id =>params[:topic_ids].split(","))
    Topic.transaction do
      topics.each do |topic|
        topic.destroy
      end
      return render :text => "sueccess"
    end
    return render :text => "faild"
  end

  
end
