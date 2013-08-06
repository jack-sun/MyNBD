require 'nbd/remote_ssh'
class West::ArticlesController < ArticlesBaseController
  include NBD::RemoteSsh
  layout "western"
  before_filter :init_ads
  
  before_filter :check_ntt_article, :only => [:show, :page]
  before_filter :forbid_the_latest_article_request_of_mobile_news, :only => [:show]
  before_filter :forbid_article_request_of_touzibao, :only => [:show]
  before_filter :forbid_article_request_of_gms, :only => [:show]

  # after_filter :only => [:show, :page] do |c|
    # path = nbd_page_cache_path
    # set = Article.get_page_cache_file_names_set(@article.id)
    # logger.debug "-----#{@article.created_at}"
    # if @article.created_at > Article::STATIC_CACHE_DEADLINE and !File.exists?(path)
    #   set << path
    #   Resque.enqueue(Jobs::WritePageCache, response.body, path)
    # end
    # return unless perform_caching
    # path = West::ArticlesController.page_cache_path(path)
    # Rails.logger.info("===path:#{path}")
    # instrument_page_cache :write_page, path do
    #   FileUtils.makedirs(File.dirname(path))
    #   File.open(path, "wb+") { |f| f.write(content) }
    # end
    # write_body('dog', '192.168.11.21',response.body, "/home/dog/temp/article_#{@article.id}.html", sudo = false)
  # end

  # after_filter :only => [:show, :page] do |c|

  #   static_setting = YAML.load(File.open(Settings.static_setting_path))
  #   article_detail_setting = static_setting['static_page_path']['article_detail']
  #   article_dir_path = article_detail_setting['dir_path']
  #   date = @article.created_at.strftime("%Y-%m-%d")
  #   file_path = article_dir_path.gsub('$subdomain', 'west').gsub('$date', date).gsub('$article_id', @article.id.to_s)
  #   file_path = File.join(file_path, article_detail_setting['page_dir_path'].gsub('$page_index', @page.p_index.to_s)) if request.path.include?("page")
  #   Resque.enqueue(Jobs::WritePageCache, response.body, "#{file_path}.html")
  # end  
  
  def show
    init_article_page(1, true)    
    record_click_count(@article)
  end
  
  def page
    init_article_page(params[:page_id], true)  
    record_click_count(@article)  
    render :show    
  end

end
