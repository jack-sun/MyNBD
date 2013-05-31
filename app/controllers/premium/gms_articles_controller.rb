#encoding:utf-8
class Premium::GmsArticlesController < ApplicationController
	layout "touzibao"
	before_filter :current_user
	# temp solution for touzibao's sign_in by zhou
	before_filter FlashTouzibaoFilter, :only => [:show, :buy]
  	before_filter :authorize , :except => [:introduce, :search, :questions, :out_link, :index, :home_page]
  	before_filter :current_gms_article, :except => [:index, :search, :questions, :out_link, :home_page]
  	before_filter :authorize_gms_account, :only => [:show]
  	before_filter :authorize_gms_token, :except => [:search, :questions, :out_link, :index, :home_page]

  	def index
		@gms_articles_type = params[:gms_articles_type]
  		@gms_articles_type = 'all' if @gms_articles_type.nil?
  		@gms_articles = if @gms_articles_type == 'paid'
			@current_user.gms_articles
		elsif @gms_articles_type == 'preview'
			GmsArticle.published.on_shelf.preview
		elsif @gms_articles_type == 'official'
			GmsArticle.published.on_shelf.official
  		else
			GmsArticle.published.on_shelf
  		end
  		# @gms_articles = @gms_articles.preview if params[:is_preview] == 'true'
  		# @gms_articles = @gms_articles.official if params[:is_preview] == 'false'
  		@gms_articles = @gms_articles.determined if params[:meeting_at] == 'determined'
  		@gms_articles = @gms_articles.includes([:stock,:article])
  		@gms_articles = @gms_articles.order("#{params[:order_by]} #{params[:order_sort]}") if params[:order_by].present?
  		@gms_articles = @gms_articles.order('pos DESC','id DESC').page(params[:page]).per(10)

	end

	def show
		@article = @gms_article.article
		record_click_count(@article)
		@comments = @article.comments.published.order("id DESC").includes(:owner)
		@page = @article.pages.where(:p_index => params[:p_index] || 1).first
	end

	def buy
		@current_user.pay_for_gms_article(@gms_article)
		session[:jumpto] = premium_gms_article_url(@gms_article)
		return redirect_to :action => :show,:gms_article_id => @gms_article.id
	end

	def refund
		gms_article = GmsArticle.find(params[:gms_article_id])
		credits = @current_user.refund_gms_article(gms_article)
		return redirect_to premium_gms_articles_path(:paid => true), :notice => "返点成功！返回#{credits}点，您当前的点数为：#{@current_user.credits}"
	end

	def questions
		if params.has_key?(:stock_code)
			@stock = Stock.where(:code => params[:stock_code]).first
			@questions = @stock.stock_comments.published.order('id desc').page(params[:page]).per(10) if @stock.present?
			@no_stock = true if @stock.nil?
		end
		@_come_back = true if @current_user.nil?
		@stock_comment = StockComment.new
	end

	def search
		@stock_code = params[:stock_code]
		@stock = Stock.where(:code => params[:stock_code]).first
		@gms_articles = []
		@gms_articles = @stock.gms_articles.published.on_shelf.page(params[:page]).per(10) if @stock.present?
		@latest_gms_articles = GmsArticle.published.on_shelf.order('id desc').limit(10)
		# return redirect_to premium_gms_articles_path
	end

	def out_link
		@gms_articles = GmsArticle.published.on_shelf.order('pos DESC','id DESC').limit(params[:count] || 10)
		return render :layout => false
	end

	def home_page
		@current_item = 'gudongdahuishilu'
		@gms_articles = GmsArticle.published.on_shelf.order('pos DESC','id DESC').limit(params[:count] || 10) 
	end	

	private

	def current_gms_article
		# return redirect_to premium_search_stock_path(:stock_code => params[:stock_code]) if params[:id] == 'search'
		# return redirect_to premium_question_stock_path(:stock_code => params[:stock_code]) if params[:id] == 'questions'
		@gms_article = GmsArticle.find(params[:gms_article_id] || params[:id])
	end

	def authorize_gms_account
		return redirect_to new_premium_gms_accounts_path(:article_id => params[:id]) if @current_user.gms_account.nil?	#to be a gms_account member first!
		unless @gms_article.user_status?(@current_user)	#the current user didn't buy the article
			flash.keep(:note) unless flash[:note].blank?
			return redirect_to premium_gms_article_pay_path(@gms_article) if @current_user.credits >= @gms_article.cost_credits	#pay for the article from uses's credits!
			# session[:jumpto] = premium_gms_article_url(@gms_article)
			session[:jump_to_gms] = premium_gms_article_url(@gms_article)
			return redirect_to pay_premium_gms_accounts_path(:gms_article_id => @gms_article.id)	#pay for the article from alipay and return to whether pay for it from users's credits! 
		end
	end

	def authorize_gms_token
		Rails.logger.info("------input_Cookie:#{cookies[:gms_access_token]}")

		return true if @current_user.gms_account.nil?
		
		token = @current_user.gms_account.check_access_token(cookies[:gms_access_token])
		unless token
			# update_user_session
			session[:jumpto] = request.url if request.url.present?
			User.online_users.delete(@current_user.id) if @current_user
    		update_user_session nil
    		cookies.delete(:CHKIO, :domain => Settings.session_domain)
    		session = nil
			return render :template => 'premium/gms_articles/conflict_sign_out'
		else
			cookies[:gms_access_token] = token
		end
		Rails.logger.info("------output_Cookie:#{cookies[:gms_access_token]}")
	end
end
