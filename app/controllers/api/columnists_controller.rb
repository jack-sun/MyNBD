require 'nbd/cache_filter'
class Api::ColumnistsController < ApplicationController

  skip_before_filter :authenticate
  
  include Api::ApiUtils 
  include Nbd::CacheFilter

  def last_update
    @columnists = nil
    str = find_by_rails_cache_or_db("views/#{columnist_articles_key_by_id('index_table', true, request.url.chomp("/"))}", :expire_in => Columnist::EXPIRE_IN) do
            @columnists = Columnist.where("last_article_id is not null").order("last_article_id desc").includes(:last_article => [:pages, :image]).page(params[:page]).per(15)
            @articles = @columnists.map do |c|
                          article = c.last_article
                          article.c_id = c.id
                          article
                        end
            Rails.logger.debug "############------#{@articles.inspect}"
            render_to_string(:file => "/api/articles/rolling_news.json.rabl")
          end
    return render :text => str
  end

  def articles
    @columnist = Columnist.where(:id => params[:id]).first
    return :json => {"msg" => "invalid parameters"}.to_json if @columnist.nil?
    str = find_by_rails_cache_or_db("views/#{columnist_articles_key_by_id(@columnist.id, true, request.url.chomp("/"))}", :expire_in => Columnist::EXPIRE_IN) do
            @articles = @columnist.articles.order("id DESC").includes(:pages => :image).page(params[:page]).per(15)
            render_to_string(:file => "/api/articles/rolling_news.json.rabl")
          end
    return render :text => str
  end
end
