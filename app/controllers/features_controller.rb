#encoding:utf-8
class FeaturesController < ApplicationController
  layout "feature"
  before_filter :init_feature, :only => [:show, :page]
  before_filter :access_control_for_specify_feature,  :only => [:show]
  
  def index
    
  end
  
  def show
    @page = @feature.feature_pages.order("pos asc").first
    @sections = JSON.parse @page.layout
    @poll_element_ids = Element.where(:type => "ElementPoll").select(:id).map(&:id)
    record_click_count
  end

  def page
    @page = @feature.feature_pages.where(:pos => params[:page_id].to_i - 1 ).first
    @sections = JSON.parse @page.layout
    @poll_element_ids = Element.where(:type => "ElementPoll").select(:id).map(&:id)
    record_click_count
    
    render :show
  end

  def init_feature
    @feature = Feature.where(:id => params[:id]).first
    return true if params[:preview] and session[:staff_id]
    raise ActiveRecord::RecordNotFound if @feature.blank? or (not @feature.is_published?)
  end
  
  private
  
  def record_click_count
    # TODO: update click_count, will move this logic into cache 
    Feature.increment_counter(:click_count, @feature.id)
  end 

  def access_control_for_specify_feature
    if params[:id].to_i == 216
      if @current_user.present?
        return render :text => "抱歉，您需要购买每经投资宝-天天赢家 1年期套餐 才能免费访问该专题内容，<a href=\"#{new_premium_mobile_newspaper_account_url}\">立即购买</a>".html_safe unless @current_user.pay_one_year_for_touzibao?
      else
        session[:jumpto] = request.url if request.url.present?
        redirect_to user_sign_in_url, :notice => "温馨提示：您需要登录后才能进行更多的操作！" 
        return
      end
    end
  end
end
