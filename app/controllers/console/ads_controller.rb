class Console::AdsController < ApplicationController
  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_common_console

  def index
    @ad_p = AdPosition.find(params[:ad_position_id])
    @ads = @ad_p.ads
  end

  def new
    @ad = Ad.new(:ad_position_id => params[:ad_p_id])
  end

  def create
    @ad = Ad.new({:staff_id => current_staff.id}.merge(params[:ad]))
    if @ad.save
      redirect_to console_ad_positions_url
    else
      render :new
    end
  end

  def edit
    @ad = Ad.find(params[:id])
  end

  def update
    @ad = Ad.find(params[:id])
    if @ad.update_attributes(params[:ad])
      redirect_to console_ad_positions_url
    else
      render :update
    end
  end

  def destroy
    @ad = Ad.find(params[:id])
    @ad.destroy
    redirect_to :back
  end

  def active
    @ad = Ad.find(params[:id])
    @ad.cp_image
    AdPosition.update_all({:current_ad_id => @ad.id}, {:id => @ad.ad_position_id})
    render :js => "window.location.reload()"
  end
  
end
