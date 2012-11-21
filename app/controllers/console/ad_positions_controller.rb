class Console::AdPositionsController < ApplicationController
  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_common_console
  before_filter :init_ads

  def index
    @ad_positions = AdPosition.includes(:current_ad => :image)
  end

  def update_size
    @ad_position = AdPosition.find(params[:ad_p_id])
    render :text => "#{@ad_position.width}x#{@ad_position.height}"
  end

  private
  def init_ads
    @common_navs = "ads"
  end
end
