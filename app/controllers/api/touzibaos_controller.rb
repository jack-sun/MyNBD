#encoding:utf-8
require 'nbd/cache_filter'
class Api::TouzibaosController < Api::ApiBaseController
  include Api::ApiUtils

  include Nbd::CacheFilter
  EXPIRE_IN = 1000
  # skip_filter :current_user
  before_filter :current_mn_account_by_token
  before_filter :get_latest_touzibao, :except => [:terms, :plans]
  before_filter :authorize_mn_account, :except => [:terms, :plans, :latest]

  # after_filter :record_activity_user
  # attr_accessor :current_device

  before_filter PremiumFilter, :if => lambda{|controller| 
    return controller.access_least_touzibao 
  }

 after_filter RecordActiveUserFilter, :if => lambda{|controller|
   return controller.access_least_touzibao 
 }  

  # before_filter AccessTokenFilter, :if => lambda{|controller|
  #   if controller.params[:action] == "today"
  #     return true 
  #   end
  #   if controller.params[:action] == "specify" and 
  #     controller.get_latest_touzibao.try(:t_index) == controller.params[:id]
  #     return true
  #   end
  #   return false
  # }
  # before_filter AppKeyFilter

  def today
    @touzibao = @latest_touzibao
    return render :json => {:error => "not found"}, :status => 404 if @touzibao.nil?
      str = find_by_rails_cache_or_db("views/#{touzibao_content_key_by_id('today', true, 'today')}", :expire_in => EXPIRE_IN) do
          render_to_string(:file => "/api/touzibaos/today.json.rabl")
      end
    hashObj = JSON.parse(str).merge({:access_token => @mn_account.try(:valid_access_token) || ""})
    return render :text => hashObj.to_json
  end

  def latest
    limit_count = params[:count] || 7
    is_valid_premium_account = (@mn_account.present? && @mn_account.account_valid?)
    @touzibaos = if is_valid_premium_account 
                   Touzibao.published.order("id desc").limit(limit_count)
                 else
                   Touzibao.published.where(["created_at < ? or id = ?", 2.week.ago.end_of_day, @latest_touzibao.id]).order("id desc").limit(limit_count)
                 end
    Rails.logger.info("----Cache----Cache:latest_#{is_valid_premium_account}_#{limit_count}")                 
    str = find_by_rails_cache_or_db("views/#{touzibao_content_key_by_id("latest", true, "latest_#{is_valid_premium_account}_#{limit_count}")}", :expire_in => EXPIRE_IN) do
        render_to_string(:file => "/api/touzibaos/latest.json.rabl")
      end

    hashObj = JSON.parse(str).merge({:access_token => @mn_account.try(:valid_access_token) || ""})
    return render :text => hashObj.to_json
  end
  
  def specify
    return render :json => {:error => "该期刊不存在"}, :status => 400 unless check_parameter([:id])
    @touzibao = Touzibao.published.where(:t_index => params[:id]).first
    return render :json => {:error => "该期刊不存在"}, :status => 404 if @touzibao.nil?

    if params[:editon].to_i == 1
    str = find_by_rails_cache_or_db("views/#{touzibao_content_key_by_id(@touzibao.id, true)}", :expire_in => EXPIRE_IN) do
        render_to_string(:file => "/api/touzibaos/touzibao.json.rabl")
      end
    elsif params[:editon].to_i == 2
      str = render_to_string(:file => "/api/touzibaos/today.json.rabl")
    end

    hashObj = JSON.parse(str).merge({:access_token => @mn_account.try(:valid_access_token) || ""})
    return render :text => hashObj.to_json
  end

  def plans
    render :json => {
                      :plans => [
                        {
                          :apple_product_id => "cn.com.nbd.Touzibao.1_year",
                          :desc => "1年 580元 ( 原价720元, 节省140元 )",
                          :type => 3,
                          :price => 580
                        },
                        {
                          :apple_product_id => "cn.com.nbd.Touzibao.6_months",
                          :desc => "6个月 300元 ( 原价360元, 节省60元 )",
                          :type => 2,
                          :price => 300
                        },
                        {
                          :apple_product_id => "cn.com.nbd.Touzibao.3_months",
                          :desc => "3个月 160元 ( 原价180元, 节省20元 )",
                          :type => 1,
                          :price => 160
                        },
                        {
                          :apple_product_id => "cn.com.nbd.Touzibao.1_month",
                          :desc => "1个月",
                          :type => 0,
                          :price => 60
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

  # def record_activity_user
  #   MnAccount.record_active_user(@mn_account)
  # end

  def current_mn_account
    return @mn_account
  end

  def access_least_touzibao
    if self.params[:action] == "today"
      return true 
    end
    if self.params[:action] == "specify" and 
      Touzibao.last_period_t_index < self.params[:id] and self.params[:access_token].present?
      return true
    end
    return false    
  end

end
