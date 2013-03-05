#encoding:utf-8
class Console::Premium::GmsArticlesController < ApplicationController
	layout 'console'
	before_filter :current_staff
	before_filter :authorize_staff
	before_filter :init_mobile_newspaper_console
  before_filter :current_gms_article,:except => [:index,:new,:create,:update,:search]

  cache_sweeper Sweepers::PageSweeper, Sweepers::ArticleSweeper, :only => [:create, :update, :destroy, :publish, :ban, :off_shelf]

	def index
    @console_search = true
		@gms_articles_type = 'index'
		@gms_articles = GmsArticle.order('pos DESC','id DESC').page(params[:page]).per(30)
	end

	def new
		@gms_articles_type = 'new'
		@gms_article = GmsArticle.new({:is_preview => GmsArticle::PREVIEW_SALE})
    @article = @gms_article.build_article({:allow_comment => true})
	end

	def create
		gms_params = params[:gms_article]
    article_params = params[:article]
    @gms_article = current_staff.create_gms_article(gms_params, article_params)


    if @gms_article.errors.empty?
		  return redirect_to console_premium_gms_articles_path	
    else
      @article = @gms_article.article
      Rails.logger.info("=====GA====:#{@article.new_record?}")
      return render :new
    end
  end

  def edit
  		@article = @gms_article.article
  end

	def update
		gms_params = params[:gms_article]
    article_params = params[:article]
    unless params.has_key?(:action_type)
      @gms_article = current_staff.create_gms_article(gms_params, article_params, 'update')
      if @gms_article.errors.empty?
        return redirect_to console_premium_gms_articles_path  
      else
        @article = @gms_article.article
        Rails.logger.info("=====GA====:#{@article.new_record?}")
        return render :new
      end
    end
  	@gms_article = GmsArticle.find(params['gms_id'])
  	@article = @gms_article.article
  	Article.transaction do
  		@gms_article = @gms_article.update_attributes!(gms_params)
  		@article = @article.update_self(article_params)
  	end
		return redirect_to console_premium_gms_articles_path
	end
 
 	def publish
 		# @gms_article = GmsArticle.find(params[:id])
 		@gms_article.publish
 		return redirect_to console_premium_gms_articles_path
 	end

 	def ban
 		# @gms_article = GmsArticle.find(params[:id])
 		@gms_article.ban
 		return redirect_to console_premium_gms_articles_path
 	end

 	def destroy
 		# @gms_article = GmsArticle.find(params[:id])
 		@gms_article.destroy
 		return redirect_to console_premium_gms_articles_path
 	end

  def show
    @show_type = 'console'
    @article = @gms_article.article
    @comments = @article.comments.order("id DESC").includes(:owner)
    @page = params.has_key?(:p_index) ? @article.pages.where(:p_index => params[:p_index]).first : @article.pages.where(:p_index => 1).first
    return render :template => "premium/gms_articles/show",:layout => 'mobile_newspaper'
  end

  def refund
    gms_article = GmsArticle.find(params[:id])
    gms_article.refund_credits
    return redirect_to console_premium_gms_articles_path
  end

  def off_shelf
    gms_article = GmsArticle.find(params[:id])
    gms_article.refund_credits
    return redirect_to console_premium_gms_articles_path
  end  

  def change_pos
    gms_article = GmsArticle.find(params[:id])
    target_gms_article = GmsArticle.find(params[:target_id])
    text = gms_article.change_pos(target_gms_article) if gms_article.present? && target_gms_article.present?
    render :text => text
  end

  def search
    @console_search = true
    @stock_code = params[:stock_code]
    @stock = Stock.where(:code => params[:stock_code]).first
    @gms_articles = []
    @gms_articles = @stock.gms_articles.published.on_shelf.page(params[:page]).per(10) if @stock.present?
    return render :index
  end  

  def to_top
    gms_article = GmsArticle.find(params[:id])
    target_gms_article = GmsArticle.order('pos DESC').first
    gms_article.change_pos(target_gms_article) if gms_article.present? && target_gms_article.present?
    return redirect_to console_premium_gms_articles_path  
  end

  private
  def current_gms_article
    @gms_article = GmsArticle.find(params[:id])
  end
end
