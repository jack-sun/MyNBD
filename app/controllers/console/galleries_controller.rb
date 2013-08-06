#encoding: utf-8
class Console::GalleriesController < ApplicationController

  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console

  UPDATE_FAILED = 0
  UPDATE_SUCCESS = 1

  def index
    @galleries = Gallery.scoped.order('id desc').page(params[:page]).per(20)
  end

  def new
    @gallery = Gallery.new
  end

  def create
    @gallery = Gallery.new(params[:gallery])
    @gallery.staff_id = current_staff.id
    if @gallery.save
      redirect_to edit_console_gallery_url(@gallery)
    else
      render :new
    end
  end

  # edit after create
  def edit
    @gallery = Gallery.where(:id => params[:id]).first
    if @gallery.present?
      @gallery_images = @gallery.gallery_images
      session[:update_failed_redirect] = :edit
    else
      flash[:error] = "没有该图片集！"
      redirect_to console_galleries_url and return
    end
  end

  def update
    @gallery = Gallery.where(:id => params[:id]).first
    # begin
    @gallery.update_with_gallery_images(params[:gallery])
    # rescue ActiveRecord::Rollback
    #   unless request.xhr?
    #     render session[:update_failed_redirect] and return
    #   else
    #     render :text => UPDATE_FAILED and return
    #   end
    # else
    flash[:notice] = session[:update_failed_redirect] == :edit ? "图片集发布成功！" : "图片集更新成功！"
    session.delete :update_failed_redirect
    unless request.xhr?
      redirect_to console_galleries_url and return
    else
      render :text => UPDATE_SUCCESS and return
    end
    # end
  end

  def destroy
    @gallery = Gallery.where(:id => params[:id]).first
    if @gallery.destroy
      flash[:notice] = "图片集删除成功！"
      redirect_to console_galleries_url and return
    else
      @galleries = Gallery.scoped.order('id desc').page(params[:page]).per(20)
      render :index and return
    end
  end

end
