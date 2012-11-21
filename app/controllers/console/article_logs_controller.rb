class Console::ArticleLogsController < ApplicationController
  # GET /console/article_logs
  # GET /console/article_logs.xml
  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_common_console
  
  def index
   init_article_logs
  end
  
  def banned
    init_article_logs(ArticleLog::BAN)
    render :index
  end
  
  def deleted
    init_article_logs(ArticleLog::DELETE)
    render :index
  end
  
  def published
    init_article_logs(ArticleLog::PUBLISH)
    render :index
  end
  
  def updated
    init_article_logs(ArticleLog::UPDATE)
    render :index
  end

  def detail
    @article_id = params[:article_id]
    @article_logs = ArticleLog.where(:article_id => @article_id).includes(:staff)
  end
  
  private
  
  def init_article_logs(cmd=nil)
    @article_ids = if cmd.present?
      ArticleLog.select("distinct(article_id)").where(:cmd => cmd).order("id desc").page(params[:page]).per(30)
    else
      ArticleLog.select("distinct(article_id)").order("id desc").page(params[:page]).per(30)
    end
    
    @article_logs = ArticleLog.select([:article_id, :article_title, :cmd, :created_at, :staff_id]).includes(:staff).where(:article_id => @article_ids.map(&:article_id)).to_a.group_by{|x|x.article_id}
    @article_logs.each do |k, v|
      @article_logs[k] = v.sort_by{|x|x.created_at.to_i}.last
    end
    
    @common_navs = cmd
  end

end
