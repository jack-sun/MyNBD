#encoding:utf-8
class Console::Premium::TouzibaoArticlesController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_mobile_newspaper_console
  before_filter :init_touzibao

    cache_sweeper Sweepers::PageSweeper, Sweepers::ArticleSweeper, :only => [:destroy, :create, :update]
  def new
    @touzibao = Touzibao.find(params[:touzibao_id])
    @article = Article.new(:status => 1)
  end

  def create
    @article = nil
    save_success = false
    Article.transaction do
      section = params[:article].delete(:section)
      params[:article][:title] = "每经投资宝(#{Date.today.strftime("%Y-%m-%d")})-#{section}"
      @article = @current_staff.create_article(params[:article], false)
      @touzibao.article_touzibaos.create(:article_id => @article.id, :pos => @touzibao.max_pos, :section => section)
      @touzibao.increment!(:max_pos)
      save_success = true
    end
    if @article.errors.size > 0 or !save_success
      return render :action => :new
    end
    return redirect_to console_premium_touzibao_path(@touzibao)
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    save_success = false
    Article.transaction do
      section = params[:article].delete(:section)
      params[:article][:title] = "每经投资宝(#{Date.today.strftime("%Y-%m-%d")})-#{section}"
      @article.update_self(params[:article])
      article_touzibao = @article.article_touzibao
      article_touzibao.update_attributes({:section => section})
      save_success = true
    end
    if @article.errors.size > 0 or !save_success
      return render :edit
    else
      return redirect_to console_premium_touzibao_path(@touzibao)
    end
    
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    redirect_to console_premium_touzibao_path(@touzibao)
  end

  private
  def init_touzibao
    @touzibao = Touzibao.find(params[:touzibao_id])
  end
  
end
