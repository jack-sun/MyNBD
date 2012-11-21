#encoding: utf-8
class NewspapersController < ApplicationController
  
  layout "site"
  
  before_filter :current_user

  after_filter :only => [:today, :show] do |c|
    path = nbd_page_cache_path
    if !File.exists?(path)
      Resque.enqueue(Jobs::WritePageCache, response.body, path)
      Resque.enqueue_in(Column::PAGE_CACHE_EXPIRE_TIME, Jobs::DeletePageCache, "column", path)
    end
  end
  
  def index
    
  end
  
  def show
    #@newspaper = Newspaper.find(params[:id])
    @newspaper = Newspaper.published.where(:n_index => params[:id]).first
    if @newspaper.blank?
      render :text => "抱歉，没有找到 #{params[:id]} 的报纸"
      return
    end
    
    @articles_newspapers = @newspaper.articles_newspapers.includes(:article => :pages).order("page ASC")
  end

  def today
    @newspaper = Newspaper.published.last
    @articles_newspapers = @newspaper.articles_newspapers.includes(:article => :pages).order("page ASC")
    
    render :show
  end

end
