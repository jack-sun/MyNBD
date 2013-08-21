class Ntt::ArticlesController < ArticlesBaseController
  USER_NAME = "nbdthinktank"
  PASSWORD = "socialntt"
  #before_filter :ntt_authenticate
  
  layout "think_tank"
  #before_filter :authorize
  before_filter :init_ads

  before_filter :forbid_article_request_of_touzibao, :only => [:show]

  # after_filter :only => [:show, :page] do |c|
  #   path = nbd_page_cache_path
  #   set = Article.get_page_cache_file_names_set(@article.id)
  #   logger.debug "-----#{@article.created_at}"
  #   if @article.created_at > Article::STATIC_CACHE_DEADLINE and !File.exists?(path)
  #     set << path
  #     Resque.enqueue(Jobs::WritePageCache, response.body, path)
  #   end
  # end

  def show
    @article = Article.where(:id => params[:id]).first
    raise ActiveRecord::RecordNotFound if @article.blank? or (not @article.is_published?)
    columnist = @article.columnists.first
    @recently_articles = columnist.articles.published.order('id DESC').limit(10) if columnist
    @first_column = @article.columns.where(:parent_id => 56).first
    
    @comments = @article.comments.order("id DESC").includes(:owner)
    
    @reporters = @article.staffs.reporters
    @editors_in_charge = @article.staffs.editors_in_charge
    
    @page = @article.pages.where(:p_index => 1).first
    
    record_click_count(@article)
  end
  
  def page
    @article = Article.where(:id => params[:id]).first
    raise ActiveRecord::RecordNotFound if @article.blank? or (not @article.is_published?)
    columnist = @article.columnists.first
    @recently_articles = columnist.articles.published.order('id DESC').limit(10) if columnist    
    @comments = @article.comments.order("id DESC").includes(:owner)
    
    @reporters = @article.staffs.reporters
    @editors_in_charge = @article.staffs.editors_in_charge
    
    @page = @article.pages.where(:p_index => params[:page_id]).first
    raise ActiveRecord::RecordNotFound if @page.blank?

    record_click_count(@article)
    
    render :show
  end
  
  private
  
  def record_click_count(article)
    # TODO: update click_count, will move this logic into cache 
    Article.increment_counter(:click_count, article.id)
    
    # for redis hot cache
    t = Time.now
    CacheCallback::BaseCallback.increment_count("click_count", article) if article.record_hot_article?
    Rails.logger.debug "############# cache callback cost time : #{Time.now - t}"
  end
  
  def ntt_authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
    end
  end
end
