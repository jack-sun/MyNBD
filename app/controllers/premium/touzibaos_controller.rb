#encoding:utf-8
class Premium::TouzibaosController < ApplicationController
  layout "mobile_newspaper"

  before_filter :current_user
  before_filter :get_last_touzibao, :except => [:last_week]
  before_filter :authorize , :except => [:introduce]
  #before_filter :check_premium_user, :only => [:today]

  def today
    @touzibao = @last_touzibao
    params[:id] = @touzibao.t_index
    if check_premium_user
      @touzibao_articles = @touzibao.article_touzibaos.includes(:article => :pages).order("pos asc, section asc")
      @is_valid = true
      render :show
      return
    else
      redirect_to last_week_premium_touzibaos_url
      return
    end
  end

  #permarlink for previous touzibao, added by Vincent, at 2012-11-12
  def yesterday
    @touzibao = @last_touzibao.pre
    params[:id] = @touzibao.t_index
    @touzibao_articles = @touzibao.article_touzibaos.includes(:article => :pages).order("pos asc, section asc")
    @is_valid = true

    render :show
  end

  def last_week
    @touzibao = Touzibao.last_valid_touzibao_for_common(2.week.ago.end_of_day)
    params[:id] = @touzibao.t_index

    @touzibao_articles = @touzibao.article_touzibaos.includes(:article => :pages).order("pos asc, section asc")
    @is_valid = true

    render :show
  end

  def show
    @touzibao = Touzibao.published.where(:t_index => params[:id]).first
    return render :show if @touzibao.nil?
    if @touzibao.t_index > Touzibao.last_valid_t_index
      if check_premium_user
        @is_valid = true 
        @touzibao_articles = @touzibao.article_touzibaos.includes(:article => :pages).order("pos asc, section asc")
      end
    else
      @touzibao_articles = @touzibao.article_touzibaos.includes(:article => :pages).order("pos asc, section asc")
      @is_valid = true
    end
  end

  private
  def check_premium_user
    @current_user && @current_user.is_valid_premium_user?
  end

  def get_last_touzibao
    @last_touzibao = Touzibao.published.last
  end
  
end
