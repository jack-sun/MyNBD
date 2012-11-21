#encoding:utf-8
class FeaturesController < ApplicationController
  layout "feature"
  before_filter :init_feature, :only => [:show, :page]
  
  def index
    
  end
  
  def show
    @page = @feature.feature_pages.order("pos asc").first
    @sections = JSON.parse @page.layout
    @poll_element_ids = Element.where(:type => "ElementPoll").select(:id).map(&:id)
    record_click_count
  end

  def page
    @page = @feature.feature_pages.where(:pos => params[:page_id].to_i - 1 ).first
    @sections = JSON.parse @page.layout
    @poll_element_ids = Element.where(:type => "ElementPoll").select(:id).map(&:id)
    record_click_count
    
    render :show
  end

  def init_feature
    @feature = Feature.where(:id => params[:id]).first
    return true if params[:preview] and session[:staff_id]
    raise ActiveRecord::RecordNotFound if @feature.blank? or (not @feature.is_published?)
  end
  
  private
  
  def record_click_count
    # TODO: update click_count, will move this logic into cache 
    Feature.increment_counter(:click_count, @feature.id)
  end 

end
