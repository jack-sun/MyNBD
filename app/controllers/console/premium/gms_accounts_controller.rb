#encoding:utf-8
class Console::Premium::GmsAccountsController < ApplicationController
	layout 'console'
	before_filter :current_staff
	before_filter :authorize_staff
	before_filter :init_mobile_newspaper_console
  	before_filter :current_gms_article,:except => [:index,:new,:create,:update,:search]

  	cache_sweeper Sweepers::PageSweeper, Sweepers::ArticleSweeper, :only => [:create, :update, :destroy, :publish, :ban, :off_shelf]

	def index
    @console_search = true
		@gms_articles_type = 'paid_users'
		@paid = true
		@paid = false if params[:paid] == 'false'
		@gms_accounts = GmsAccount.paid if @paid
		@gms_accounts = GmsAccount.un_paid unless @paid
		@gms_accounts = @gms_accounts.order('id DESC').page(params[:page]).per(20)
	end


  def show
    @show_type = 'console'
    @article = @gms_article.article
    @comments = @article.comments.order("id DESC").includes(:owner)
    @page = params.has_key?(:p_index) ? @article.pages.where(:p_index => params[:p_index]).first : @article.pages.where(:p_index => 1).first
    return render :template => "premium/gms_articles/show",:layout => 'mobile_newspaper'
  end



  def search
  	@console_search = true
    @gms_accounts = []
  	users = User.where("nickname like ?","%#{params[:nickname].strip}%")
  	users.each do |user|
  		@gms_accounts.push(user.gms_account) if user.gms_account.present?
  	end
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
