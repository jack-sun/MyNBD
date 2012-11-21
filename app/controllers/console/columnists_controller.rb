class Console::ColumnistsController < ApplicationController
  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console
  def index
    @columnists = Columnist.page(params[:page])
  end

  def new
    @columnist = Columnist.new
  end

  def create
    @columnist = Columnist.new({:staff_id => current_staff.id}.merge!(params[:columnist]))
    if @columnist.save
      redirect_to console_columnists_path
    else
      render :new
    end
  end

  def edit
    @columnist = Columnist.where(:slug => params[:id]).first
  end

  def update
    @columnist = Columnist.where(:slug => params[:id]).first
    if @columnist.update_attributes(params[:columnist])
      redirect_to console_columnists_path
    else
      render :edit
    end
  end

  def destroy
    @columnist = Columnist.where(:slug => params[:id]).first
    @columnist.destroy
    redirect_to console_columnists_path
  end
end
