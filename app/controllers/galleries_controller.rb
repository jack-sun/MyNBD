class GalleriesController < ApplicationController

  layout false

  after_filter :increase_click_count, :only => [:show] do
    return if params[:perview] == "true"
  end

  def show
    @gallery = Gallery.where(:id => params[:id]).first
    redirect_to index_url and return if @gallery.blank? || (@gallery.status == Gallery::STATUS_UNPUBLISH && params[:preview] != "true")
    gallery_articles = @gallery.articles
    if gallery_articles.present?
      @gallery_article_column = gallery_articles.first.columns.first
      @gallery_article_parent_column = @gallery_article_column.visable_parent
    end
    gallery_images = @gallery.gallery_images
    @gallery_images = gallery_images.to_json(:methods => :image_url) if gallery_images.present?
    @hot_galleries = Gallery.hot_galleries
    @recommend_galleries = @gallery.recommend_galleries
  end

  private

  def increase_click_count
    if @gallery.try(:status) == Gallery::STATUS_PUBLISHED && session[:staff_id].blank?
      @gallery.increase_click_count
      CacheCallback::BaseCallback.increment_count("click_count", @gallery)
    end
  end

end
