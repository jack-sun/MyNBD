# encoding: utf-8
class ArticlesController < ArticlesBaseController
  
  before_filter :check_ntt_article, :only => [:print, :show, :page]
  before_filter :forbid_the_latest_article_request_of_mobile_news, :only => [:show,:print]
  before_filter :forbid_article_request_of_touzibao, :only => [:show,:print]
  before_filter :forbid_article_request_of_gms, :only => [:show,:print]

  skip_filter :current_article, :split_article_id, :only => [:rolling_news]

  layout 'site_v3'
  
  # caches_page :show, :page

  # after_filter :only => [:show, :page] do |c|
  #   subdomain = request.subdomains.first
  #   date = @article.created_at.strftime("%Y-%m-%d")
  #   file_path = get_static_article_path(subdomain, @article.id, date, @page.p_index)
  #   Resque.enqueue(Jobs::WritePageCache, response.body, file_path)
  # end
  
  def print
    
    @reporters = @article.staffs.select{|e| e.is_reporter?}
    @editors_in_charge = @article.staffs.select{|e| e.is_editor_in_charge?}
    @pages = @article.pages
    render(:template=>'articles/print', :layout=>'layouts/print')
  end
  
  def show
    init_article_page
    record_click_count(@article)
    if (Column::DIS_SUB_NAVS[Column::SHANGHAI_COLUMN_ID] & @article.columns.map(&:id)).present?
      @render_shanghai_skin = true
    end
    # render_article
    return render :show
  end
  
  def page
    init_article_page(params[:page_id])   
    record_click_count(@article)
    if (Column::DIS_SUB_NAVS[Column::SHANGHAI_COLUMN_ID] & @article.columns.map(&:id)).present?
      @render_shanghai_skin = true
    end
    # render_article
    return render :show
  end
  
  def rolling_news
    @featured_articles = {:articles => Article.of_column(7, 4), :id => 7} #频道精选
    @focus_articles = {:articles => Article.of_column(8, 5), :id => 8} #媒体聚焦
    @rolling_articles = Article.published.rolling.order('id DESC').page(params[:page]).per(15)
  end

  private
  


  # def check_ntt_article
  #   @article = Article.find(params[:id])
  #   raise ActiveRecord::RecordNotFound if @article.blank? or (not @article.is_published?)
  #   return redirect_to ntt_article_url(@article) if @article.from_ntt?
  # end
  
  def render_article
    if @article.is_notice?
      return render :show_simple
    else
      if @article.is_in_cache_period?
        return  render :show
      else
        return  render :show_with_out_cache
      end
    end
  end


  # def forbid_the_latest_article_request_of_mobile_news
  #   if (ArticlesColumn.where({:column_id => Column::MOBILE_NEWS_COLUMN, :status => Article::PUBLISHED}).order("pos desc").first).try(:article_id) == params[:id].to_i
  #     return true if  session[:staff_id]
  #     raise ActiveRecord::RecordNotFound
  #   end
  # end
  
end
