# encoding: utf-8
require 'nbd/utils'
class Console::NewspapersController < ApplicationController
  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console

  cache_sweeper Sweepers::NewspaperSweeper, Sweepers::ArticleSweeper, :only => [:create, :update, :destroy, :publish, :unpublish, :create_article]
  
  # GET /newspapers
  # GET /newspapers.xml
  def index
    @newspapers = Newspaper.order("id DESC").page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @newspapers }
    end
  end

  # GET /newspapers/1
  # GET /newspapers/1.xml
  def show
    @newspaper = Newspaper.find(params[:id])
    @articles_newspapers = @newspaper.articles_newspapers.includes({:article => [{:columns => :parent}, :staffs, :pages, :children_articles, :weibo]}).order("page ASC").page(params[:page]).per(100)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @newspaper }
    end
  end

  # GET /newspapers/new
  # GET /newspapers/new.xml
  def new
    @newspaper = Newspaper.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @newspaper }
    end
  end

  # GET /newspapers/1/edit
  def edit
    @newspaper = Newspaper.find(params[:id])
  end

  # POST /newspapers
  # POST /newspapers.xml
  def create
    saved_newspaper = Newspaper.where(:n_index => params[:n_index]).first
    return redirect_to edit_console_newspaper_path(saved_newspaper) if saved_newspaper
    
    newspaper = current_staff.newspapers.create(:n_index => params[:n_index])
    redirect_to edit_console_newspaper_path(newspaper)
  end

  # PUT /newspapers/1
  # PUT /newspapers/1.xml
  def update
    @newspaper = Newspaper.find(params[:id])
    saved_pages = @newspaper.saved_pages
    temp_pages = []
    current_page = nil
    files = params[:files]
    if files.blank?
      flash[:error] = "请选择文件后提交"  
      return redirect_to :back
    end
    #saved_pages = []
    files.each do |file|
      filename = file.original_filename
      next unless filename.end_with?(".trs")
      articles_data = NBD::Utils.parse_daily_news(file.tempfile)
      next if articles_data.blank?
      current_page = articles_data.first["page"].to_s
      next if saved_pages.include?(current_page)
      Newspaper.transaction do
        @newspaper.add_articles(articles_data)
      end
      saved_pages << current_page
      temp_pages << current_page
    end
    @can_upload = (Newspaper::ALL_PAGES - saved_pages).blank?
    if temp_pages.compact.blank?
      flash[:notice] = "刚才的文件没有包含新闻信息"
    else
      @newspaper.updated_at = Time.now
      @newspaper.save
      flash[:notice] = "#{saved_pages.join(", ")} 版的文章已经上传成功！"
    end 
    redirect_to console_newspaper_path(@newspaper)
 end

  # DELETE /newspapers/1
  # DELETE /newspapers/1.xml
  def destroy
    @newspaper = Newspaper.find(params[:id])
    @newspaper.destroy

    respond_to do |format|
      format.html { redirect_to(console_newspapers_url) }
      format.xml  { head :ok }
    end
  end

  def publish
    @newspaper = Newspaper.find(params[:id])
    @newspaper.status = Newspaper::STATUS_PUBLISHED
    @newspaper.save!
    redirect_to console_newspapers_path
  end

  def unpublish
    @newspaper = Newspaper.find(params[:id])
    @newspaper.status = Newspaper::STATUS_DRAFT
    @newspaper.save!
    redirect_to console_newspapers_path
  end

  def upload_file
    uploader = NewspaperUploader.new
    uploader.store!(params[:temp_file])
    hash = Newspaper.get_file_status_hash_key(params[:newspaper_id])
    filename = params[:temp_file].original_filename
    Rails.logger.debug "####{hash[filename]}"
    if hash[filename] == Newspaper::STATUS_PARSE_SUCCESS.to_s or hash[filename] == Newspaper::STATUS_PARSE.to_s
      return render :text => [{:name => params[:temp_file].original_filename, :repeat => true}].to_json
    end
    Resque.enqueue(Jobs::NewspaperJob, "#{uploader.to_s}", params[:newspaper_id])
    hash[filename] = Newspaper::STATUS_PARSE
    render :text => [{:name => params[:temp_file].original_filename}].to_json
  end

  def new_article
    @newspaper = Newspaper.find(params[:id])
  end

  def create_article
    @newspaper = Newspaper.find(params[:id])
    articles_data = params.dup
    articles_data.delete('id')
    articles_data['content'] = articles_data['content'].split("\r\n").each{|line| line.gsub(/\u3000/, ' ')};
    if articles_data['content'].join(" ").scan("如需转载请与《每日经济新闻》报社联系").present?
      content_line_number = articles_data['content'].size
      copyright_line_number = 5
      articles_data['content'].slice!(content_line_number-copyright_line_number, content_line_number)
    end
    articles_data['copyright'] = Article::COPYRIGHT_YES
    articles_data = Array.wrap(articles_data)
    @newspaper.add_articles(articles_data)
    redirect_to console_newspaper_path(@newspaper)
  end

  def check_status
    render :text => Newspaper.get_file_status_hash_key(params[:id]).all.to_json
  end
end
