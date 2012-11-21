class Console::ArticlesChildrenController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console
  cache_sweeper Sweepers::PageSweeper, Sweepers::ArticleSweeper
  def create
    article = Article.find(params[:articles_children].delete(:article_id))
    @child = article.add_child_article(params[:articles_children])
    unless @child.save!
      render :js => "alert('error!')"
    end
  end

  def update
    @child = ArticlesChildren.find(params[:id])
    @child.article.update_attribute(:updated_at, Time.now)
    unless @child.update_attributes!(params[:articles_children])
      render :js => "alert('error!')"
    end
  end

  def new_article
    @root_article = Article.find(params[:root_article_id])
    article = @current_staff.create_article(params[:article])
    if article.save!
      @child = @root_article.add_child_article(article)
#      if request.xhr?
#        render :js => "location.reload();"
#      else
        redirect_to :back
#      end
    end
  end
end

