class Console::Premium::TouzibaoCasesController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_mobile_newspaper_console
  cache_sweeper Sweepers::PageSweeper, Sweepers::ArticleSweeper, :only => [:destroy, :create, :update]

  def index
    @touzibao_nav_type = "case_index"
    @current_column = Column.find(Column::TOUZIBAO_CASE_COLUMN)
    @articles_columns = @current_column.articles_columns.order("pos desc").includes({:article => [{:columns => :parent}, :staffs, :pages, :children_articles, :weibo]}).page params[:page]
  end

  def new
    @touzibao_nav_type = "case_index"
    @article = Column.find(Column::TOUZIBAO_CASE_COLUMN).articles.new(:allow_comment => false) 
    @article.status = "1"
  end

  def edit
    @touzibao_nav_type = "case_index"
    @article = Article.find(params[:id])
  end

  def create
    @article = @current_staff.create_article(params[:article], true)
    if @article.errors.size > 0
      column = Column.where(:id => params[:column_id]).first
      @selected_id = column.nil? ? -1 : column.id
      return render :action => :new
    end
    return redirect_to console_premium_touzibao_cases_path
  end
  
  def update
    @article = Article.find(params[:id])
    @article.update_self(params[:article])
    if @article.errors.size > 0
      return render :edit
    else
      return redirect_to console_premium_touzibao_cases_path
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
