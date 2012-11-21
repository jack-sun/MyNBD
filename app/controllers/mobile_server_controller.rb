require 'base64'
require 'json'

class MobileServerController < ApplicationController
  
  CLIENT_TYPE_ANDROID = "android"
  CLIENT_TYPE_IPHONE = "iphone"
  
  TRANSACTOIN_NAMES = %w{loadColumnArticles}
  
  CODE_PARAMS_INVALID = -5
  CODE_CMD_INVALID = -4
  CODE_CLIENT_TYPE_INVALIDE = -3
  CODE_PROTOCOL_VERSION_EXPIRED = -2
  CODE_AUTHORIZE_FAILURE = -1
  CODE_OPERATION_FAILURE = 0
  CODE_SUCCESS = 1
  
  CMD_NEW = 1
  CMD_UPDATE = 2
  CMD_EXPIRE = 3
  CMD_DELETE = 4
  #CMD_SEARCH = 5
  
  MSG_CODE_FAILED = 0
  MSG_CODE_SUCCESS = 1
  
  class NotAuthorizedError < StandardError; end
  class InvalidClientError < StandardError; end
  class InvalidCmdError < StandardError; end
  class InvalidInputParamsError < StandardError; end
  class ServerError < StandardError; end
  
  def index
    result = transact()
    render_resp(result) if result
  end
  
  private
  
  def transact
    params ||= self.params
    
    pv = params[:pv]
    cv = params[:cv]
    s = params[:s]
    
    @client = params[:ct]
    logger.debug "@client: #{@client.inspect}"
    
    case @client
      when CLIENT_TYPE_ANDROID then
      #TODO synchronize
      logger.debug "#{CLIENT_TYPE_ANDROID} client app, synchronize"
      when CLIENT_TYPE_IPHONE then
      #TODO synchronize
      logger.debug "#{CLIENT_TYPE_IPHONE} client app, synchronize"
    else
      raise InvalidClientError
    end
    
    #TODO get current user
    #    @user = session[:user]
    #    unless @user
    #      raise NotAuthorizedError
    #    end
    
    # reject invalid commands
    cmd = params[:cmd]
    raise InvalidCmdError if cmd.blank? || !TRANSACTOIN_NAMES.include?(cmd)
    
    # ignore the bad request spawn
    raise InvalidInputParamsError if params[:json].nil?
    
    json = Rack::Utils.unescape(params[:json])
    json_data = params[:json] ? JSON.parse(params[:json]) : nil
    raise InvalidInputParamsError if json_data.nil?
    send("transact_#{cmd.underscore}", json_data)
    
  rescue NotAuthorizedError
    logger.error "user authorized failure.\n#{$!}"
    @code = CODE_AUTHORIZE_FAILURE
    @message = "user authorized failure"
  rescue InvalidClientError
    logger.error "invalid client error.\n#{$!}"
    @code = CODE_CLIENT_TYPE_INVALIDE
    @message = "invalid client"
  rescue InvalidCmdError
    logger.error "invalid cmd.\n#{$!}"
    @code = CODE_CMD_INVALID
    @message = "invalid cmd : #{cmd}"
  rescue InvalidInputParamsError
    logger.error "invalid input params.\n#{$!}"
    @code = CODE_PARAMS_INVALID
    @message = "invalid params : #{params.inspect}.\n#{$!}"
  rescue Exception => e
    logger.error "client transaction error.cmd : #{cmd}\n#{$!}\n#{e.inspect}"
    @code = CODE_OPERATION_FAILURE
    @message = "client transaction error."
  end
  
  ##
  # Writes response content
  def render_resp(result)
    resp = {
      :result => result,
      :code => defined?(@code) ? @code : CODE_SUCCESS,
      :message => defined?(@message) ? @message : ""
    }
    resp[:user_id] = @user.present? ? @user.id : nil
    
    status = (defined?(@code) && @code != CODE_SUCCESS) ? 404 : 200
    
    case @client
      when CLIENT_TYPE_ANDROID then
      render_resp_default(resp, status)
    else
      render_resp_default(resp, status)
    end
  end
  
  def render_resp_default(resp,status=200)
    headers["Content-Type"] = "text/plain; charset=UTF-8"
    render(:text => resp.to_json, :status => status) #Rack::Utils.escape
  end
  
  #_DESC: load column articles
  def transact_load_column_articles(data)
    resp = {:msg => "", :articles => []}
    
    count = (data["count"] || 15).to_i
    load_old_data = (data["load_old_data"] || 0).to_i
    time = (data["time"] || 0).to_i
    column_id = (data["column_id"] || 0) .to_i
    load_rolling_news = (data["load_rolling_news"] || 0).to_i 
    raise InvalidInputParamsError if load_rolling_news == 0 and column_id == 0
    
    articles = []
    if load_rolling_news == 1
      if column_id == 0
        articles = Article.rolling
      else
        column = Column.where(:id => column_id).first
        raise InvalidInputParamsError if column.blank?
        articles = column.articles.rolling
      end
    else
      column = Column.where(:id => column_id).first
      raise InvalidInputParamsError if column.blank?
      articles = column.articles
    end
    if load_old_data == 1
      articles = articles.where(["articles.created_at < ?", Time.at(time)])
    end
    articles = articles.order("articles.id DESC").includes({:pages => :image}).page(0).per(count)
    
    articles.each do|article|
    content = ""
    
    article_hash = {:id => article.id.to_s, :title => article.title, :url => article_url(article), :digest => article.show_digest, :content => content,
       :column_id => column_id.to_s, :is_rolling_news => article.is_rolling_news, :images => [], :created_at => article.created_at.to_i.to_s, :updated_at => article.updated_at.to_i.to_s}
    article.pages.each do|p|
    content += "<p>" + p.content + "</p>"
    
    if p.p_index == 1 and p.image.present?
      if column_id == 2 # head news
        article_hash[:images] << p.image.article_url(:x_large)
      else # thumbnails
        article_hash[:images] << p.image.article_url(:middle)  
      end
    end
  end
  
  article_hash[:content] = resp_article_content(article, content)
  
  resp[:articles] << article_hash
end

resp
end

private
def resp_article_content(article, content)
render_to_string(:partial => "article_content", :locals => {:article => article, :content => content.html_safe})
end

end
