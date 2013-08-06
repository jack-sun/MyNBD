require 'rubygems'
require 'fileutils'
require 'chinese_pinyin'
require 'nbd/utils'
require 'action_pack'
require './app/helpers/application_helper'
require 'static_page/util'
# include Rails.application.routes.url_helpers
include ActionView::Helpers::TagHelper
include StaticPage::Util
include ApplicationHelper
class Jobs::UpdateStaticFragmentPage

  @queue = :article_fragment_static_page
  
  def self.perform(article_id = nil, options = nil)
    fresh_article_detail_pages(article_id) if article_id
    fresh_column_static_pages(options) unless options.blank?
  end

  private
  class << self
    def fresh_article_detail_pages(article_id)
        article = Article.find_by_id(article_id)
        if article
          delete_article_static_page(article_id, article.created_at.strftime("%Y-%m-%d"))
          update_recommend_articles_fragments(article)
          update_article_related_features_fragments(article)
          simulate_visit_proxy(article_url(article))
        end
    end

    def fresh_column_static_pages(options)
      options.each do |update_type, column_ids|
        case update_type.to_sym
          when :column_top_picks_pages
            update_column_top_picks_page(column_ids)
          when :hot_articles
            update_column_hot_articles_page
          when :column_picture_articles
            update_column_picture_articles(column_ids)
          when :hot_picture_articles
            update_hot_picture_articles
        end 
      end
    end
  end
end
