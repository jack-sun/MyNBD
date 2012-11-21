# encoding: utf-8
class Console::FeaturesController < ApplicationController
  
  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console
  cache_sweeper Sweepers::FeaturePageSweeper, :only => [:update, :destroy]
  
  def index
    @features = Feature.includes(:staff, :feature_pages).order("created_at DESC").page(params[:page])
  end
  
  def new
    @feature = Feature.new(:allow_comment => false)
  end
  
  def create
    @feature = @current_staff.features.new({:allow_comment => false}.merge(params[:feature]))
    
    if @feature.save
      redirect_to edit_console_feature_path(@feature, :new_record => true)
    else
      render :new
    end
  end
  
  def edit
    @feature = Feature.where(:id => params[:id]).first
    @pages = @feature.feature_pages.order("pos asc")
    #@elements = @page.elements_dict
    #@sections = JSON.parse(@page.layout)
  end
  
  def update
    @feature = Feature.where(:id => params[:id]).first
    preview = params[:feature].delete(:preview)
    params[:feature][:theme] = params[:theme_bg]
    @feature.update_attributes!(params[:feature])
    delete_image = params[:feature][:bg_image_attributes] && params[:feature][:bg_image_attributes][:remove_feature] == "1"
    if delete_image
      image = Image.find(params[:feature][:bg_image_attributes][:id])
      image.remove_feature!
      image.clear_uploader(:feature)
    end
    if preview == "1"
      if request.xhr?
        return render :js => "window.open('#{feature_url(@feature, :preview => true)}','previewWindow');"
      else
        return render :text => "<script type='text/javascript'>window.open('#{feature_url(@feature, :preview => true)}','previewWindow');</script>"
      end
      #return render :text => "<script type='text/javascript'>window.open('#{feature_url(@feature, :preview => true)}')</script>"
    elsif params[:update_banner]
      return render :text => "<script type='text/javascript'>window.close();</script>"
    else
      if request.xhr?
        render :js => "window.location='#{console_features_url}';"
      else
        render :text => "<script type='text/javascript'>window.location='#{console_features_url}';</script>"
      end
      #return render :text => "<script type='text/javascript'>window.location='#{console_features_url}'</script>"
    end
  end
  
  def destroy
    @feature = Feature.where(:id => params[:id]).first
    @feature.destroy
    
    redirect_to console_features_path
  end

  def update_banner
    @feature = Feature.where(:id => params[:id]).first
    render :update_banner, :layout => "element"
  end

  def image_cell_frame
    render :image_cell_frame, :layout => "element"
  end
  
end
