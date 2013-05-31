#encoding:utf-8
class Premium::MobileNewsController < ApplicationController
  layout "touzibao"

  def introduce
    #article_columns = Column.find(Column::MOBILE_NEWS_COLUMN).articles_columns.order("pos desc")
    #.where("created_at < ?", Time.now.beginning_of_day).first
    article_columns = Column.find(Column::MOBILE_NEWS_COLUMN).articles_columns.order("pos desc")
    .where(:status => Article::PUBLISHED).offset(1).first
    @article = article_columns.try(:article)
  end

end
