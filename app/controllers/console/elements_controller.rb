class Console::ElementsController < ApplicationController
  layout "element"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  cache_sweeper Sweepers::ElementSweeper, :only => [:update, :destroy]
  after_filter do
    Rails.logger.debug "---------------------------------#{response.body}"
  end
  
  def index
    @owner = if params[:feature_page_id].present?
      FeaturePage.where(:id => params[:feature_page_id]).first
    elsif params[:topic_id].present?
      Topic.where(:slug => params[:topic_id]).first
    end
  end
  
  def new
    @owner = if params[:feature_page_id].present?
      FeaturePage.where(:id => params[:feature_page_id]).first
    elsif params[:topic_id].present?
      Topic.where(:slug => params[:topic_id]).first
    end
    
    @k_name = params[:type].downcase
    raise unless Element::ELEMENT_TYPES.include?(@k_name)
    
    @element = Class.const_get("Element#{@k_name.camelize}").new
    
    render @k_name.to_sym
  end
  
  def create
    @owner = if params[:feature_page_id].present?
      FeaturePage.where(:id => params[:feature_page_id]).first
    elsif params[:topic_id].present?
      Topic.where(:slug => params[:topic_id]).first
    end     
    
    @k_name = params[:type].downcase
    element = Class.const_get("Element#{@k_name.camelize}").new(params["element_#{@k_name}"])
    @owner.elements << element
    
    if @owner.class.to_s == FeaturePage.name
      render :text => "<script type='text/javascript'>document.domain='#{Settings.domain.split('.')[1..-1].join('.')}';window.opener._layoutOpts.addElementcallback(#{element.id}, '#{element.class.name.underscore}', '#{element.title}', #{@owner.pos + 1});window.close();</script>";
    else
      render :text => "<script type='text/javascript'>document.domain='#{Settings.domain.split('.')[1..-1].join('.')}';window.opener._layoutOpts.addElementcallback(#{element.id}, '#{element.class.name.underscore}', '#{element.title}', 1);window.close();</script>"; 
    end
  end
  
  def edit 
    @element = Element.find(params[:id])
    @owner = @element.owner
    @k_name = @element.class.to_s.gsub("Element", "").underscore
    begin
      @body = JSON.parse(@element.content)["body"]
    rescue Exception
      @body = {}
    end
    
    render @k_name.to_sym
  end
  
  def update
    @element = Element.find(params[:id])
    @owner = @element.owner
    @k_name = @element.class.to_s.underscore
    
    @element.update_attributes!(params[@k_name.to_sym])
    
      render :text => "<script type='text/javascript'>document.domain='#{Settings.domain.split('.')[1..-1].join('.')}';window.opener._layoutOpts.updateElementcallback(#{@element.id}, '#{@element.title}');window.close();</script>";
    #if request.xhr?
      #render :js => "window.opener._layoutOpts.updateElementcallback(#{@element.id}, '#{@element.title}');window.close()";
    #else
      #render :text => "<script type='text/javascript'>window.opener._layoutOpts.updateElementcallback(#{@element.id}, '#{@element.title}');window.close();</script>";
    #end
  end
  
  def destroy
    @element = element = Element.find(params[:id])
    @owner = @element.owner
    @element.destroy
    
    if @owner.class.to_s == FeaturePage.name
      render :text => "<script type='text/javascript'>document.domain='#{Settings.domain.split('.')[1..-1].join('.')}';window.opener._layoutOpts.removeElementcallback(#{@element.id}, #{@owner.pos + 1});window.close();</script>";
    else
      render :text => "<script type='text/javascript'>document.domain='#{Settings.domain.split('.')[1..-1].join('.')}';window.opener._layoutOpts.removeElementcallback(#{@element.id}, 1);window.close();</script>";
    end
  end
  
  def show
    
  end
  
  def related_articles
    @articles = @current_user.articles.order("created_at DESC").page(0).per(20)
    
    render :text => render_to_string(:partial => "console/elements/related_articles", :layout => false)
  end
  
end
