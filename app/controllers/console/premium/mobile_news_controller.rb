#encoding:utf-8
class Console::Premium::MobileNewsController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_mobile_newspaper_console
  cache_sweeper Sweepers::PageSweeper, Sweepers::ArticleSweeper, Sweepers::ColumnistSweeper, :only => [:destroy, :update, :create]

  def index
    @mobile_news_type = "index"
    @current_column = Column.find(Column::MOBILE_NEWS_COLUMN)
    @articles_columns = @current_column.articles_columns.order("pos desc").includes({:article => [{:columns => :parent}, :staffs, :pages, :children_articles, :weibo]}).page params[:page]
  end

  def new
    @mobile_news_type = "new"
    @article = Column.find(Column::MOBILE_NEWS_COLUMN).articles.new(:allow_comment => false) 
    @article.status = "1"
    @article.title = "每经投资快讯:#{Time.now.strftime("%Y-%m-%d")}"
  end

  def edit
    @mobile_news_type = "index"
    @article = Article.find(params[:id])
  end

  def create
    @article = @current_staff.create_article(params[:article], false)
    if @article.errors.size > 0
      column = Column.where(:id => params[:column_id]).first
      @selected_id = column.nil? ? -1 : column.id
      return render :action => :new
    end
    return redirect_to console_premium_mobile_news_index_path
  end
  
  def update
    @article = Article.find(params[:id])
    @article.update_self(params[:article])
    if @article.errors.size > 0
      return render :edit
    else
      return redirect_to console_premium_mobile_news_index_path
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.columns.each do |c|
      c.updated_at = Time.now
      c.save!
    end
    columnists = @article.columnists.to_a
    @article.destroy
    columnists.each(&:update_last_article)
    redirect_to :back
  end
  
end
