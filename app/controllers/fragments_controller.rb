#encoding:utf-8
require 'static_page/util.rb'
class FragmentsController < ApplicationController

  include ::StaticPage::Util

  after_filter :write_static_page, :only => [:article_detail_fragment_missing]

  def fragment_missing
    # render :text => "您需要的文件未找到！"
    render :text => ""
  end

  def article_detail_fragment_missing
    article_id, file_name = params[:file_name].split('_')
    article = Article.find(article_id)
    if article
      @file_path = get_static_article_path(Settings.default_sub_domain, article.id, article.created_at.strftime("%Y-%m-%d"), 1, true)
      @file_path += "_#{file_name}.html"
      @content = if file_name == 'recommend'
        update_recommend_articles_fragments(article, true)
      elsif file_name == 'features'
        update_article_related_features_fragments(article, true)
      end
      return render :text => @content
    end
  end

  private

  def write_static_page
    Resque.enqueue(Jobs::WriteStaticPage, @content, @file_path)# unless @content.blank?
  end
end
