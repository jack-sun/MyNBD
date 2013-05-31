# encoding: utf-8
class ArticlesBaseController < ApplicationController

    def init_article_page(page_index = 1 , is_west = false)
      # Rails.logger.info("Come on========is_west:#{is_west}")
      @showed_live = Live.showed_lives(Rails.cache.read(Live::LIVE_SHOW_TYPE_KEY)||"1").order("id desc").first
      @showed_live_talks = @showed_live.live_talks.where(:talk_type => LiveTalk::TYPE_TALK).includes([:weibo => :owner, :live_answers => {:weibo => :owner}]).order("id desc").limit(2) #直播
      
      @first_column = @article.columns.order("id asc").try(:to_a).try(:first)
      
      @comments = @article.comments.order("id DESC").includes(:owner)
      
      @reporters = @article.staffs.reporters
      @editors_in_charge = @article.staffs.editors_in_charge
      
      @page = @article.pages.where(:p_index => page_index).first
      
      unless is_west
        @related_articles = @article.related_articles(5) #相关文章 west hasn't
        @recommend_articles = {:id => @article.id} #根据关键词 推荐的文章, 获取文章逻辑放到页面上  west hasn't
      end
      #@recommend_articles = @article.recommend_articles(5) #根据关键词 推荐的文章
      
      @column_top_picks = @article.relate_hot_articles #频道精选
      
      #@global_hot_articles = Article.hot_articles(20)[0..9] #temp solution, Vincent 2011-12-05 #全局热门文章
      
      @nbd_weekly_comment = {:articles => Article.of_column(100, 1), :id => 100} #每经一周评
      
      #@global_hot_comment_articles = Article.hot_comment_articles(20)[0..9] #全局热评文章
      
      @featured_articles = {:articles => Article.of_column(5,4), :id => 5} #全局每日精选
      
      @focus_articles = {:articles => Article.of_column(8, 5), :id => 8} #媒体聚焦
      
      @image_news = {:articles => Article.of_column(4, 5), :id => 4} #图片新闻
      
      @hot_topics = {:topics => Topic.hot_topics(1), :id => 'hot_topic'} #社区热议
 
    end


  def forbid_article_request_of_touzibao
    if (ArticlesColumn.where(:article_id => params[:id]).map(&:column_id) & Column::FORBID_ARTICLE_REQUEST_OF_COLUMNS).present?
      raise ActiveRecord::RecordNotFound
    end
  end

  def forbid_article_request_of_gms
    if (ArticlesColumn.where(:article_id => params[:id]).map(&:column_id) & Column::GMS_ARTICLES_COLUMNS).present?
      raise ActiveRecord::RecordNotFound
    end
  end    


  def forbid_the_latest_article_request_of_mobile_news
    if (ArticlesColumn.where({:column_id => Column::MOBILE_NEWS_COLUMN, :status => Article::PUBLISHED}).order("pos desc").first).try(:article_id) == params[:id].to_i
      return true if  session[:staff_id]
      raise ActiveRecord::RecordNotFound
    end
  end

  def check_ntt_article
    @article = Article.find(params[:id])
    raise ActiveRecord::RecordNotFound if @article.blank? or (not @article.is_published?)
    return redirect_to ntt_article_url(@article) if @article.from_ntt?
  end

  def record_click_count(article)
    # Rails.logger.info("==========Come on Record click:========")
    # TODO: update click_count, will move this logic into cache 
    unless session[:staff_id]
      Article.increment_counter(:click_count, article.id)
      
      # for redis hot cache
      t = Time.now
      CacheCallback::BaseCallback.increment_count("click_count", article) if article.record_hot_article?
      Rails.logger.debug "############# cache callback cost time : #{Time.now - t}"
    end
  end

end
