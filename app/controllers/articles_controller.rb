# encoding: utf-8
class ArticlesController < ArticlesBaseController
  before_filter :check_ntt_article, :only => [:print, :show, :page]
  before_filter :forbid_the_latest_article_request_of_mobile_news, :only => [:show,:print]
  before_filter :forbid_article_request_of_touzibao, :only => [:show,:print]
  before_filter :forbid_article_request_of_gms, :only => [:show,:print]
  
  layout 'site'
  after_filter :only => [:show, :page] do |c|
    path = nbd_page_cache_path
    set = Article.get_page_cache_file_names_set(@article.id)
    logger.debug "-----#{@article.created_at}"
    if @article.created_at > Article::STATIC_CACHE_DEADLINE and !File.exists?(path)
      set << path
      Resque.enqueue(Jobs::WritePageCache, response.body, path)
    end
  end
  
  def print
    
    @reporters = @article.staffs.select{|e| e.is_reporter?}
    @editors_in_charge = @article.staffs.select{|e| e.is_editor_in_charge?}
    @pages = @article.pages
    render(:template=>'articles/print', :layout=>'layouts/print')
  end
  
  def show
    init_article_page
    record_click_count(@article)
    render_article
  end
  
  def page
    init_article_page(params[:page_id])   
    record_click_count(@article)
    render_article
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
