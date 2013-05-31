# encoding: utf-8
class Mobile::ArticlesController < ArticlesBaseController

  layout 'mobile', :except => [:plain]

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
    if @article.blank? or (not @article.is_published?)
      return render :text => "文章不存在！" 
      #raise ActiveRecord::RecordNotFound
    end

    @first_column = @article.columns.order("id asc").first

    @reporters = @article.staffs.reporters
    @editors_in_charge = @article.staffs.editors_in_charge

    @page = @article.pages.where(:p_index => 1).first

    record_click_count(@article)
  end

  def page
    @article = Article.where(:id => params[:id]).first
    if @article.blank? or (not @article.is_published?)
      return render :text => "文章不存在！" 
    end

    @first_column = @article.columns.order("id asc").first

    @reporters = @article.staffs.reporters
    @editors_in_charge = @article.staffs.editors_in_charge

    @page = @article.pages.where(:p_index => params[:page_id]).first

    record_click_count(@article)

    render :show
  end

  def plain
    @article = Article.find(params[:id])
    @content = ""
    @article.pages.each do |p|
      @content += "<p>" + p.content + "</p>"
    end
  end
  

  # private

  # def record_click_count(article)
  #   # TODO: update click_count, will move this logic into cache 
  #   Article.increment_counter(:click_count, article.id)

  #   # for redis hot cache
  #   t = Time.now
  #   CacheCallback::BaseCallback.increment_count("click_count", article)
  #   Rails.logger.debug "############# cache callback cost time : #{Time.now - t}"
  # end

end
