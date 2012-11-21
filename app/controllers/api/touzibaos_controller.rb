#encoding:utf-8
class Api::TouzibaosController < ApplicationController
  skip_filter :current_user
  before_filter :current_user_by_token, :except => [:latest]
  before_filter :get_latest_touzibao, :except => [:terms, :plans]
  attr_accessor :current_device

  before_filter PremiumFilter, :if => lambda{|controller| 
    if controller.params[:action] == "today"
      return true 
    end
    if controller.params[:action] == "specify" and 
      controller.get_latest_touzibao.try(:t_index) == controller.params[:id]
      return true
    end
    return false
  }

  before_filter AccessTokenFilter, :if => lambda{|controller|
    if controller.params[:action] == "today"
      return true 
    end
    if controller.params[:action] == "specify" and 
      controller.get_latest_touzibao.try(:t_index) == controller.params[:id]
      return true
    end
    return false
  }
  before_filter AppKeyFilter

  def today
    @touzibao = @latest_touzibao
    return render :json => {:error => "not found"}, :status => 404 if @touzibao.nil?
    render :file => "api/touzibaos/today.json.rabl"
  end

  def latest
    @touzibaos = Touzibao.published.order("id desc").limit(params[:count] || 7)
  end
  
  def specify
    return render :json => {:error => "not found"}, :status => 400 unless check_parameter([:id])
    @touzibao = Touzibao.published.where(:t_index => params[:id]).first
    return render :json => {:error => "not found"}, :status => 404 if @touzibao.nil?
    render :file => "api/touzibaos/touzibao.json.rabl"
  end

  def plans
    render :json => {
                      :plans => [
                        {:desc => "fffffffff",
                         :type => 1
                        }
                      ]
                    }
  end

  def terms
    render :json => {
      :signup_term => render_to_string(:file => "general/privacy.html.erb", :layout => "mobile_api"),
      :service_term => render_to_string(:file => "general/mobile_newspaper_privacy.html.erb", :layout => "mobile_api")
    }
  end



  def get_latest_touzibao
    @latest_touzibao ||= Touzibao.published.order("id desc").first
  end

end
