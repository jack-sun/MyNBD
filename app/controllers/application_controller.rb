#encoding: utf-8
require 'pp'
require 'nbd/utils'
require 'logger/logger_patch'
require 'uri'
class ApplicationController < ActionController::Base
  AD_TYPE_INDEX = 1
  AD_TYPE_ARTICLE = 2
  AD_TYPE_COUMN = 3
  AD_TYPE_ALL = 4
  include SimpleCaptcha::ControllerHelpers
  protect_from_forgery
  before_filter :current_user

  after_filter do
    self.logger.last_log_message = ""
  end

  rescue_from Exception, :with => :render_all_errors
  
  def render_all_errors(exception)
    if Rails.env.production?
      case exception
      when ActiveRecord::RecordNotFound, ActionController::RoutingError, ActionController::UnknownAction
        render(:file => "#{Rails.root}/public/404.html", :status => 404, :layout => false)
      else
        WebsiteLog.error(self, request, exception)
        render(:file => "#{Rails.root}/public/500.html", :status => 500, :layout => false)
      end
    else
      raise exception
    end
  end

  def with_subdomain(subdomain)
    subdomain ||= ""
    subdomain += "." unless subdomain.blank?
    [subdomain, request.domain(Settings.domain_length.to_i), request.port_string].join("")
  end
  
  def url_for(options = nil)
    if options.is_a? Hash and !options[:subdomain].blank?
      options[:host] = with_subdomain(options.delete(:subdomain))
    end
    super(options)
  end
  helper_method :url_for

  def ntt_article_url(article, html_suffix = true)
    if article.redirect_to.present?
  	  article.redirect_to
  	else
    	url = "#{Settings.ntt_host}/articles/#{article.created_at.strftime("%Y-%m-%d")}/#{article.id}"
    	url += ".html" if html_suffix
    	url
    end
  end
  helper_method :ntt_article_url
  
  def current_user
    Rails.logger.info '###################'
    Rails.logger.info "#######{session[:user_id]}"
    Rails.logger.info '###################'
    return @current_user if @current_user.present?
    @current_user = session[:user_id].present? ? User.where(:id => session[:user_id]).first : nil
    unless @current_user.present? 
      @current_user = User.where(:auth_token => cookies[:CHKIO]).first if cookies[:CHKIO].present?
      update_user_session(@current_user) if @current_user.present?
    end
    
    User.online_users[@current_user.id] = Time.now.to_i if @current_user.present?
    @current_user
  end
  helper_method :current_user

  def check_access_token
    return render :json => {:error => "invalid access_token"}, :status => 401 unless @current_user.check_access_token(params[:access_token])
  end
  
  def authorize
    unless @current_user.present?
      if request.subdomain(Settings.domain_length) == "api"
        return render :json => {:error => "登陆后才能继续操作"}, :status => 401
      end
      session[:jumpto] = request.url if request.url.present?
      redirect_to user_sign_in_url, :notice => "温馨提示：您需要登录后才能进行更多的操作！" 
      return
    end
  end
  
  def authorize_staff
    unless @current_staff.present?
      if request.get?
        session[:jumpto] = request.fullpath
      else
        session[:jumpto] = request.env["HTTP_REFERER"]
      end
      redirect_to console_sign_in_path, :notice => "请先登录" 
      return
    end
  end
  

  def is_touzibao_premium_user?
    @current_user && @current_user.is_valid_premium_user?
  end
  helper_method :is_touzibao_premium_user?

  #TODO
  def current_staff
    @current_staff = session[:staff_id].present? ? Staff.where(:id => session[:staff_id]).first : nil
  end
  helper_method :current_staff
  
  def update_user_session(user=nil)
    logger.debug "session[:user_id]: #{session[:user_id].inspect} === 0"
    session[:user_id] = user.present? ? user.id : nil
    logger.debug "session[:user_id]: #{session[:user_id].inspect} === 1"
  end
  
  def update_staff_session(staff=nil)
    session[:staff_id] = staff.present? ? staff.id : nil
  end
  
  def auth_provider_path(provider)
    "/auth/#{provider}"
  end
  helper_method :auth_provider_path
  
  def paginate_params(limit=20 , query=:page)
    {
      :page => params[query] , 
      :per_page =>limit
    }
  end
  
  def init_news_console
    return render :text => "唉，你的权限不够啊！" unless @current_staff.authority_of_news?
    @news_console = true
  end
  
  def init_community_console
    return render :text => "唉，你的权限不够啊！" unless @current_staff.authority_of_community?
    @community_console = true
  end

  def init_mobile_newspaper_console
    return render :text => "唉，你的权限不够啊！" unless @current_staff.authority_of_mobile_news?
    @mobile_newspaper_console = true
  end
  
  def init_common_console
    return render :text => "唉，你的权限不够啊！" unless @current_staff.authority_of_common?
    @common_console = true
  end
  
  def error_message  message , action='home/err'
    unless message.blank?
      @err_message = message
      render :action=>action
    end
  end

  def render_404
    render :template => "/errors/404.html", :status => 404, :layout => false
  end
  
  def after_sign_in_and_redirect_to(user, redirect_back = false)
    if session[:jumpto].present?
      to_url = session[:jumpto]
      session[:jumpto] = nil
        
      redirect_to to_url.to_s
      return 
    elsif (params[:come_back] == "1" or redirect_back) and request.env["HTTP_REFERER"]
      redirect_to :back
      return 
    else
      redirect_to user_url(user)
      return
    end
  end

  def init_ads(ad_type = AD_TYPE_ALL)
    return nil if request.xhr? or params[:controller] =~ /^console/
    @ad_hash = Hash.new({})
    AdPosition.includes(:current_ad).each do |ad_p|
      if ad = ad_p.current_ad
        @ad_hash[ad_p.name] = {:alt => ad.title, :link => ad.link, :width => ad_p.width, :height => ad_p.height, :display => true}
      else
        @ad_hash[ad_p.name] = {:alt => "nbd", :link => "http://www.nbd.com.cn", :width => ad_p.width, :height => ad_p.height, :display => false}
      end
    end
  end
  
  def record_click_count(article)
    # TODO: update click_count, will move this logic into cache 
    Article.increment_counter(:click_count, article.id)
    
    # for redis hot cache
    t = Time.now
    CacheCallback::BaseCallback.increment_count("click_count", article) if article.record_hot_article?
    Rails.logger.debug "############# cache callback cost time : #{Time.now - t}"
  end

  def self.page_cache_file(path, extension)
    name = (path.empty? || path == "/") ? "/index" : URI.unescape(path.chomp('/'))
    unless (name.split('/').last || name).include? '.'
      name << (extension || self.page_cache_extension)
    end
    return name
  end

  def self.page_cache_path(path, extension = nil)
    page_cache_directory + page_cache_file(path, extension)
  end

  def nbd_page_cache_path
    path = self.class.page_cache_file(request.path, nil)
    path = "public/page_caches/#{request.subdomain(Settings.domain_length.to_i)}#{path}"
  end

  def format_service_card(service_card)
    service_card.scan(/\w{1,4}/).join(" ")
  end

  helper_method :format_service_card

  def forbid_request_of_mobile_news
    #      raise ActiveRecord::RecordNotFound if params[:id].to_i == Column::MOBILE_NEWS_COLUMN
  end

  def forbid_article_request_of_mobile_news
    #      if ArticlesColumn.where(:article_id => params[:id]).map(&:column_id).include?(Column::MOBILE_NEWS_COLUMN)
    #        raise ActiveRecord::RecordNotFound
    #      end
  end

  def forbid_request_of_touzibao
    raise ActiveRecord::RecordNotFound if Column::FORBID_COLUMNS.include?(params[:id].to_i)
  end

  def forbid_article_request_of_touzibao
    if (ArticlesColumn.where(:article_id => params[:id]).map(&:column_id) & Column::FORBID_ARTICLE_REQUEST_OF_COLUMNS).present?
      raise ActiveRecord::RecordNotFound
    end
  end

  def check_parameter(parame_arry)
    return (params.symbolize_keys.keys & parame_arry).present?
  end

  def current_user_by_token
    if params[:access_token].nil?
      return
    end
    @current_user ||= User.where(:access_token => params[:access_token]).first
  end

end

