class West::ArticlesController < ApplicationController

  layout "western"
  before_filter :init_ads

  before_filter :forbid_article_request_of_touzibao, :only => [:show]

  after_filter :only => [:show, :page] do |c|
    path = nbd_page_cache_path
    set = Article.get_page_cache_file_names_set(@article.id)
    logger.debug "-----#{@article.created_at}"
    if @article.created_at > Article::STATIC_CACHE_DEADLINE and !File.exists?(path)
      set << path
      Resque.enqueue(Jobs::WritePageCache, response.body, path)
    end
  end
  
  def show
    @article = Article.where(:id => params[:id]).first
    raise ActiveRecord::RecordNotFound if @article.blank? or (not @article.is_published?)
    
    @first_column = @article.columns.where(:parent_id => 145).first
    
    @comments = @article.comments.order("id DESC").includes(:owner)
    
    @reporters = @article.staffs.reporters
    @editors_in_charge = @article.staffs.editors_in_charge
    
    @page = @article.pages.where(:p_index => 1).first
    
    # Right Column
    @column_top_picks = @article.relate_hot_articles #频道精选
    
    @nbd_weekly_comment = {:articles => Article.of_column(100, 1), :id => 100} #每经一周评
    
    #@global_hot_articles = Article.hot_articles(10) #全局热门文章
    
    #@global_hot_comment_articles = Article.hot_comment_articles(10) #全局热评文章
        
    @featured_articles = {:articles => Article.of_column(5,4), :id => 5} #全局每日精选
    
    @focus_articles = {:articles => Article.of_column(8, 5), :id => 8} #媒体聚焦
    
    @image_news = {:articles => Article.of_column(4, 5), :id => 4} #图片新闻
    
    @hot_topics = {:topics => Topic.hot_topics(1), :id => 'hot_topic'} #社区热议
    
    
    record_click_count(@article)
  end
  
  def page
    @article = Article.where(:id => params[:id]).first
    raise ActiveRecord::RecordNotFound if @article.blank? or (not @article.is_published?)
    
    @comments = @article.comments.order("id DESC").includes(:owner)
    
    @reporters = @article.staffs.reporters
    @editors_in_charge = @article.staffs.editors_in_charge
    
    @page = @article.pages.where(:p_index => params[:page_id]).first
    raise ActiveRecord::RecordNotFound if @page.blank?
    
     # Right Column
    @column_top_picks = @article.relate_hot_articles #频道精选
    
    @nbd_weekly_comment = {:articles => Article.of_column(100, 1), :id => 100} #每经一周评
    
    #@global_hot_articles = Article.hot_articles(10) #全局热门文章
    
    #@global_hot_comment_articles = Article.hot_comment_articles(10) #全局热评文章
        
    @featured_articles = {:articles => Article.of_column(5,4), :id => 5} #全局每日精选
    
    @focus_articles = {:articles => Article.of_column(8, 5), :id => 8} #媒体聚焦
    
    @image_news = {:articles => Article.of_column(4, 5), :id => 4} #图片新闻
    
    @hot_topics = {:topics => Topic.hot_topics(1), :id => 'hot_topic'} #社区热议

    record_click_count(@article)
    
    render :show
  end

end
