# encoding: utf-8
class SpecialsController < ApplicationController
  USER_NAME = "nbddog"
  PASSWORD = "kbb2012cd"
  #if Rails.env.production?
    before_filter :authenticate
  #end
  
  # 散户心愿墙
  def wishwall
    @keywords = "散户心愿墙"
    @weibos = Weibo.search(@keywords, :page => params[:page], :per_page => 40, :order => :id, :sort_mode => :desc, :with => {:status => 1})
    @weibos_0, @weibos_1, @weibos_2, @weibos_3 = [], [], [], []
    
    @weibos.each_with_index do |w, index|
      case index % 4
      when 0
        @weibos_0 << w
      when 1
        @weibos_1 << w
      when 2
        @weibos_2 << w
      when 3  
        @weibos_3 << w
      end
    end
    
    render :layout => 'wishwall'
  end

  def poll_details
    @polls = Poll.where(:id => params[:poll_ids].split(","))    
  end

  private
  def authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
    end
  end

end
