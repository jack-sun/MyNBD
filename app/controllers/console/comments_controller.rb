module Console
  class CommentsController < ApplicationController
    layout 'console'
    skip_before_filter :current_user
    before_filter :current_staff
    before_filter :authorize_staff
    before_filter :init_news_console

    cache_sweeper Sweepers::CommentSweeper, :except => [:index]

    def index
      @comments_mana_nvs = true
      @comments = Comment.article_comments.includes([:owner, :article]).order("id DESC").page(params[:page])
    end

    def ban
      @comment = Comment.find(params[:id])
      @comment.status = Comment::BANNDED
      @comment.save!
      render :js => "window.location.reload();"
    end

    def unban
      @comment = Comment.find(params[:id])
      @comment.status = Comment::PUBLISHED
      @comment.save!
      render :js => "window.location.reload();"
    end

    def ban_comments
      ids = params[:comment_ids].split(",")
      comments = Comment.where(:id => ids)
      Comment.transaction do
        comments.each do |c|
          c.status = Comment::BANNDED
          c.save!
        end
        return render :text => "success"
      end
      return render :text => "faild"
    end

    def destroy_comments
      ids = params[:comment_ids].split(",")
      comments = Comment.where(:id => ids)
      Comment.transaction do
        comments.each do |c|
          c.destroy
        end
        return render :text => "success"
      end
      return render :text => "faild"
    end

    def destroy
      comment = Comment.find(params[:id])
      comment.destroy
      render :js => "window.location.reload();"
    end
  end
end
