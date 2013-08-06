class Console::ImagesController < ApplicationController
  UPDATE_DESC_SUCCESS = 1
  UPDATE_DESC_FAILD = 0

  IMAGE_COUNT_PER_PAGE = 10
  
  layout "console", :except => [:upload_images, :upload_gallery_images]

  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console
  
  # GET /console/images
  # GET /console/images.xml
  def index
    @images = Image.where("article is not null or thumbnail is not null").order("id desc").page(params[:page]).per(15)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @console_images }
    end
  end

  # GET /console/images/1
  # GET /console/images/1.xml
  def show
    @console_image = Image.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @console_image }
    end
  end

  # GET /console/images/new
  # GET /console/images/new.xml
  def new
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @console_image }
    end
  end

  # GET /console/images/1/edit
  def edit
    @image = Image.find(params[:id])
  end

  # POST /console/images
  # POST /console/images.xml
  def create
    if params[:multiple] == "false"
      @image = Image.new(params[:image])
    else
      @image = Image.new({params[:image].keys.first => params[:image].values.first.first})
    end
    type = @image.url_type
    #response.headers["Content-type"] = "text/plain"
    if @image.save
      render :text => [ @image.to_jq_upload(type, "image") ].to_json.to_s
    else 
      render :text => [ @image.to_jq_upload(type, "image").merge({ :error => "custom_failure" }) ].to_json.to_s
    end
  end

  # PUT /console/images/1
  # PUT /console/images/1.xml
  def update
    @image = Image.find(params[:id])
    type = @image.url_type
    if @image.update_attributes!(params[:image])
      if request.xhr?
        render :text => [ @image.to_jq_upload(type, "image") ].to_json.to_s
      else
        redirect_to console_images_path
      end
    else 
      if request.xhr?
        render :text => [ @image.to_jq_upload(type, "image").merge({ :error => "custom_failure" }) ].to_json.to_s
      else
        redirect_to edit_console_image_path(@image)
      end
    end
  end


  # DELETE /console/images/1
  # DELETE /console/images/1.xml
  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    redirect_to console_images_path
  end

  def upload_images
    @keyword = params[:q]
    
    @current_tab = true if params[:page] or params[:q]
    if params[:q] and params[:q].to_s.length > 0
      @images = Image.search(@keyword, :page => params[:page], :per_page => IMAGE_COUNT_PER_PAGE, :order => :id, :sort_mode => :desc)
    else
      @images = Image.order("id desc").where("article is not null or thumbnail is not null").page(params[:page]).per(IMAGE_COUNT_PER_PAGE)
    end
    render :layout => "image_insert"
  end

  def update_desc
    params_hash = {}
    gallery_id = params[:create_gallery_image]
    params[:desc_params].each do |k, v|
      params_hash[k] = {:desc => v[0..254]}
    end
    begin
      Image.update(params_hash.keys, params_hash.values)
      if gallery_id.present?
        gallery = Gallery.where(:id => gallery_id).first
        new_gallery_images = gallery.generate_gallery_image(params_hash) 
      end
    rescue ActiveRecord::Rollback
      render :text => UPDATE_DESC_FAILD and return
    end
    if gallery_id.blank?
      render :text => UPDATE_DESC_SUCCESS and return
    else
      return render :json => new_gallery_images.to_json(:methods => :thumb_s_url)
    end
  end

  def upload_gallery_images
    @gallery = Gallery.where(:id => params[:id]).first
    @image = Image.new
    render :layout => "image_insert"
  end
end
