class Console::ImagesController < ApplicationController
  UPDATE_DESC_SUCCESS = 1
  UPDATE_DESC_FAILD = 0

  IMAGE_COUNT_PER_PAGE = 10
  
  layout "console"
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
    @image = Image.new(params[:image])
    type = @image.url_type
    #response.headers["Content-type"] = "text/plain"
    if @image.save
      render :text => [ @image.to_jq_upload(type, "www") ].to_json.to_s
    else 
      render :text => [ @image.to_jq_upload(type, "www").merge({ :error => "custom_failure" }) ].to_json.to_s
    end
  end

  # PUT /console/images/1
  # PUT /console/images/1.xml
  def update
    @image = Image.find(params[:id])
    type = @image.url_type
    if @image.update_attributes!(params[:image])
      if request.xhr?
        render :text => [ @image.to_jq_upload(type, "www") ].to_json.to_s
      else
        redirect_to console_images_path
      end
    else 
      if request.xhr?
        render :text => [ @image.to_jq_upload(type, "www").merge({ :error => "custom_failure" }) ].to_json.to_s
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
    params[:desc_params].each do |k, v|
      params_hash[k] = {:desc => v}
    end
    Image.update(params_hash.keys, params_hash.values)
    return render :text => UPDATE_DESC_SUCCESS
  end
end
