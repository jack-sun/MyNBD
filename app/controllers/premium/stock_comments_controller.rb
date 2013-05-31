#encoding:utf-8
class Premium::StockCommentsController < ApplicationController
	layout "touzibao"
	before_filter :current_user

  	def create
  		if params.has_key?(:stock_code)
  			@stock = Stock.where(:code => params[:stock_code]).first
  			@stock_comment = @stock.stock_comments.create(params[:stock_comment].merge({:user_id => @current_user.id}))
  		else
  			@stock_comment = StockComment.create(params[:stock_comment].merge({:user_id => @current_user.id}))
  			@stock = Stock.where(:code => params[:stock_comment][:stock_code]).first
  		end
      @questions = @stock.stock_comments.published.order('id desc').page(params[:page]) if @stock.present?
      if @stock_comment.present? && @stock_comment.errors.empty?
  		  return redirect_to premium_question_stock_path(:stock_code => @stock.code)
      else
        return render :template => 'premium/gms_articles/questions'
      end
  	end
end
