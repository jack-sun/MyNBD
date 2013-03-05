class SearchController < ApplicationController
  
  layout "weibo"
  before_filter :current_user
  
  def article_search
    
    @keyword = params[:q]
    
    @articles = Article.search(@keyword, :page => params[:page], :per_page => 10, :order => :id, :sort_mode => :desc, :with => {:status => 1})
    
    #TODO
    #@global_hot_articles = Article.hot_articles(20)[0..9] #temp solution, Vincent 2011-12-05
    #@global_hot_comment_articles = Article.hot_comment_articles(20)[0..9] #temp solution, Vincent 2011-12-05
    
    render :layout => "site"
  end
  
  def article_tag_search
    @keyword = params[:q]
    
    @articles = Article.search(:page => params[:page], :per_page => 10, :order => :id, :sort_mode => :desc, :conditions => {:tags => @keyword})
    
    #TODO
    #@global_hot_articles = Article.hot_articles(20)[0..9] #temp solution, Vincent 2011-12-05
    #@global_hot_comment_articles = Article.hot_comment_articles(20)[0..9] #temp solution, Vincent 2011-12-05
    
    render :article_search, :layout => "site"
  end
  
  def community_search
    @keyword = params[:q]
    @type = params[:type] || "weibo"
    
    if @type == "weibo"
      @interviewee = @current_user
      @weibos = Weibo.search(@keyword, :page => params[:page], :per_page => 10, :order => :id, :sort_mode => :desc, :with => {:status => 1})
    elsif @type == "user"
      @users = User.search(@keyword, :page => params[:page], :per_page => 10, :order => :id, :sort_mode => :desc, :with => {:status => 1})
    end
  end
  
  def user_search
    @keyword = params[:q]
    
    @users = User.search(@keyword, :page => params[:page], :per_page => 10, :order => :id, :sort_mode => :desc, :with => {:status => 1})
  end
  
  def image_search
    @keyword = params[:q]
    
    @images = Image.search(@keyword, :page => params[:page], :per_page => 10, :order => :id, :sort_mode => :desc)
  end
  
  # def gms_accounts_search
  #   @keyword = params[:nick_name]

  #   @users = User.search(@keyword, :page => params[:page], :per_page => 10, :order => :id, :sort_mode => :desc, :with => {:status => 1}) 

  # end

end
