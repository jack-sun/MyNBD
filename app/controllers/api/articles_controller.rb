require 'nbd/cache_filter'
class Api::ArticlesController < ApplicationController
  include Nbd::CacheFilter

  include Api::ApiUtils
  def show
    @article = Article.find(params[:id])
  end

  def rolling_news
    @articles = nil
    @column = nil
    str = find_by_rails_cache_or_db("views/#{column_show_content_key_by_id('rolling_news', true, request.url.chomp("/"))}") do
            @column = Column.find(params[:column_id]) if params[:column_id] and params[:column_id].to_i != 0
            @articles = @column ? articles_filter(@column.articles.rolling) : articles_filter(Article.rolling)
            str = render_to_string(:file => "/api/articles/rolling_news.json.rabl")
          end
    return render :text => str
  end

  def pull_important_news
    @last_article_id = params[:last_article_id].try(:to_i) || 0

    @last_important_article_id  = Article.last_important_article_id.value.try(:to_i)
    unless @last_important_article_id
      @last_important_article_id = Article.import_articles.last.try(:id)
      Article.last_important_article_id = @last_important_article_id
      Rails.cache.delete(Article::IMPORTANT_ARTICLE_CACHE_KEY)
    end

    if @last_important_article_id and @last_article_id <  @last_important_article_id
      str = find_by_rails_cache_or_db(Article::IMPORTANT_ARTICLE_CACHE_KEY) do
        @article = Article.find(@last_important_article_id)
        @article.pos = @article.articles_columns.where(:column_id => 3).first.pos || 0
        str = render_to_string(:file => "/api/articles/pull_important_news.json.rabl")
      end
      return render :text => str
    else
      return render :json => {
                                :result => {
                                  :status => 0,
                                  :article => {}
                                },
                                :msg => "success",
                                :code => 0
                             }
    end
  end

end
