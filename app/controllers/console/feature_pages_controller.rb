class Console::FeaturePagesController < ApplicationController
  
  layout "element"
  
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  cache_sweeper Sweepers::FeaturePageSweeper, :only => [:update, :destroy]
  
  #GET
  def choose_section
    
  end
  
  #AJAX
  def delete_section
    page = FeaturePage.find(params[:id])
    
    if params[:layout].present?
      page.layout = params[:layout]
      page.save
    end
    
    Element.destroy(params[:del_element_ids]) if params[:del_element_ids].present?
    
    render :text => "done"
    
  end
  
  #GET
  def new_section
    
  end
  
  #POST
  def create_section
    
  end
  
  #AJAX
  def fetch_section_template
    @section_code = (params[:section_code] || "section_2_b").strip
    
    render :text => render_to_string(:partial => "console/feature_pages/section_template", :layout => false)
  end
  
  #POST
  def update_layout
    page = FeaturePage.find(params[:id])
    
    page.layout = params[:layout]
    page.save!
    
    render :text => "done"
  end
  
  def edit
    @page = FeaturePage.find(params[:id])
    @feature = @page.feature
    @elements = @page.elements_dict
    @sections = JSON.parse(@page.layout)
  end
  
  def update
    
  end
  
  def create
    @feature = Feature.where(:id => params[:feature_id]).first
    @page = @feature.feature_pages.create(:pos => @feature.feature_pages.count, :layout => [].to_json, :title => "").set_as_default_layout
  end
  
  def destroy
    @feature = Feature.where(:id => params[:feature_id]).first
    @page = FeaturePage.find(params[:id])
    @page.destroy
    @feature.feature_pages.update_all("pos = pos - 1", ["pos > ? ", @page.pos - 1])
    redirect_to edit_console_feature_url(@feature)
  end
  
end
