#encoding: utf-8
class Console::GalleryImagesController < ApplicationController

  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console

  DELETE_FAILED = 0
  DELETE_SUCCESS = 1

  POS_CHANGE_FAILED = 0
  POS_CHANGE_SUCCESS = 1

  def index
    gallery = Gallery.where(:id => params[:gallery_id]).first
    gallery_images = gallery.gallery_images
    respond_to do |format|
      format.json { render json: gallery_images.to_json(:methods => [:image_url, :thumb_s_url]) }
    end
  end

  def destroy
    @gallery_image = GalleryImage.where(:id => params[:id]).first
    unless @gallery_image.present?
      flash[:error] = "请求非法"
      redirect_to console_galleries_url
    end
    # begin
    GalleryImage.transaction do
      @gallery_image.sort_for_destroy
      @gallery_image.destroy
    end
    # rescue ActiveRecord::Rollback
    #   render :text => DELETE_FAILED and return
    # else
    render :text => DELETE_SUCCESS and return
    # end
  end

  def change_pos
    if request.xhr?
      pos = params[:gallery_image][:pos]
      gallery_image = GalleryImage.where(:id => params[:gallery_image][:id]).first
      # begin
      gallery_image.change_pos(pos)
      # rescue ActiveRecord::Rollback
      #   render :text => POS_CHANGE_FAILED and return
      # else
      render :text => POS_CHANGE_SUCCESS and return
      # end
    else
      flash[:error] = "非法请求"
      redirect_to console_galleries_url and return
    end
  end

end
