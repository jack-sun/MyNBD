class Console::Premium::TouzibaosController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_mobile_newspaper_console


  def index
    @touzibao_nav_type = "index"
    @touzibaos = Touzibao.order("id desc").page(params[:page]).per(20)
  end

  def new
    @touzibao_nav_type = "new"
    @touzibao = Touzibao.new(:t_index => Date.today.to_s(:db))
  end

  def show
    @touzibao = Touzibao.find(params[:id])
    @article_touzibaos = @touzibao.article_touzibaos.includes(:article).page(params[:page]).per(20).order("pos asc, section asc")
  end

  def update
    
  end

  def publish
    @touzibao = Touzibao.find(params[:id])    
    @touzibao.status = Touzibao::PUBLISHED
    @touzibao.save!
    redirect_to console_premium_touzibaos_path
  end

  def unpublish
    @touzibao = Touzibao.find(params[:id])    
    @touzibao.status = Touzibao::DRAFT
    @touzibao.save!
    redirect_to console_premium_touzibaos_path
  end

  def create
    @touzibao = @current_staff.touzibaos.build(params[:touzibao])
    if @touzibao.save
      redirect_to [:console, :premium, @touzibao]
    else
      render :new
    end
  end

  def destroy
    @touzibao = Touzibao.find(params[:id])
    @touzibao.destroy
    redirect_to console_premium_touzibaos_path
  end

  def change_pos
    moved_article_id = params[:article_id].to_i
    target_article_id = params[:target_id].to_i
    @touzibao = Touzibao.find(params[:id])
    articles = Article.where(:id => [moved_article_id, target_article_id]).to_a.group_by(&:id)
    return render :text => "faild" if articles.count < 2
    moved_article = articles[moved_article_id].first
    target_article = articles[target_article_id].first
    text = @touzibao.change_articles_pos(moved_article, target_article)
    render :text => text
  end

  def print
    @touzibao = Touzibao.find(params[:id])
    @touzibao_articles = @touzibao.article_touzibaos.includes(:article => :pages).order("pos asc, section asc")
    render :print, :layout => "mobile_newspaper"
  end
  
end
