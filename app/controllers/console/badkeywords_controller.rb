#encoding: utf-8
class Console::BadkeywordsController < ApplicationController
  
  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_community_console
  
  def index
    @keywords = Badkeyword.order("id DESC").page(params[:page]).per(20)
    @badkeywords_navs = true
  end
  
  def new
    @keyword = Badkeyword.new
    @badkeywords_navs = true
  end
  
  def create
    params[:badkeyword][:value] = params[:badkeyword][:value].gsub('*', '\*')
    @keyword = @current_staff.badkeywords.create(params[:badkeyword])
    
    redirect_to console_badkeywords_url
  end
  
  def edit
     @keyword = Badkeyword.where(:id => params[:id]).first
    @badkeywords_navs = true
  end
  
  def update
    @keyword = Badkeyword.where(:id => params[:id]).first
    @keyword.update_attributes!(params[:badkeyword])
    
    redirect_to console_badkeywords_url
  end
  
  def destroy
    @keyword = Badkeyword.where(:id => params[:id]).first
    @keyword.destroy
  end
  
end
