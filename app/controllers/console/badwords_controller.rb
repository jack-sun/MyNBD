#encoding: utf-8
class Console::BadwordsController < ApplicationController
  
  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console
  
  def index
    @keywords = Badword.order("id DESC").page(params[:page]).per(20)
  end
  
  def new
    @keyword = Badword.new
  end
  
  def create
    params[:badword][:value] = params[:badword][:value].gsub('*', '\*')
    Rails.logger.debug "-------------#{params[:badword]}"
    @keyword = @current_staff.badwords.create(params[:badword])
    
    redirect_to console_badwords_url
  end

  def search
    @q= params[:q]
    @keywords = Badword.where(["value like ?", "%#{params[:q]}%"]).order("id DESC").page(params[:page]).per(20)
    render :index
  end
  
  def edit
     @keyword = Badword.where(:id => params[:id]).first
  end
  
  def update
    @keyword = Badword.where(:id => params[:id]).first
    @keyword.update_attributes!(params[:badword])
    
    redirect_to console_badwords_url
  end
  
  def destroy
    @keyword = Badword.where(:id => params[:id]).first
    @keyword.destroy
  end

  private
  def init_badwords_nav
    @badkeywords_navs = true
  end
  
end
