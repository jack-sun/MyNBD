#encoding:utf-8
class Console::Premium::StockCommentsController < ApplicationController
  layout 'console'
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_mobile_newspaper_console

  def index
    @gms_articles_type = "comments"
    if params.has_key?(:banned)
      @stock_comments_navs = 'banned'
      @stock_comments = StockComment.banned.order('id desc').page(params[:page])
    else
      @stock_comments_navs = 'all'
      if params.has_key?(:stock_code)
        @stock = Stock.where(:code => params[:stock_code]).first
        @stock_comments = @stock.stock_comments.order('id desc').page(params[:page])
      else
        @stock_comments = StockComment.order('id desc').page(params[:page])
      end
    end
  end

  def destroy
    @stock_comment = StockComment.find(params[:id])
    
    @stock_comment.destroy
    return redirect_to console_premium_stock_comments_path
  end

  def ban
    @stock_comment = StockComment.find(params[:id])
    @stock_comment.ban
    return redirect_to console_premium_stock_comments_path
  end

  def publish
    @stock_comment = StockComment.find(params[:id])
    @stock_comment.publish
    return redirect_to console_premium_stock_comments_path
  end  
end
