require 'nbd/cache_filter'
class Api::ColumnsController < ApplicationController

  skip_before_filter :authenticate
  
  include Api::ApiUtils

  include Nbd::CacheFilter

  def articles
    @column = Column.find(@merged_params[:id])
    str = find_by_rails_cache_or_db("views/#{column_api_content_key_by_id(@column.id, true, request.url.chomp("/"))}", :expire_in => Column::EXPIRE_IN) do
            articles = @column.articles_columns
            @articles = articles_columns_filter(articles).map do |article_column|
                article = article_column.article
                article.pos = article_column.pos
                article
            end
            @articles = reverse(@articles)
            render_to_string(:file => "/api/articles/rolling_news.json.rabl")
          end
    return render :text => str
  end
end
