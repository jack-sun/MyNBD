class Ntt::ColumnistsController < ApplicationController
  USER_NAME = "nbdthinktank"
  PASSWORD = "socialntt"
  #before_filter :ntt_authenticate
  
  layout "think_tank"
  def index
    @columnists = Columnist.order("last_article_id desc").includes([{:last_article => :columns}, :image])
    @activities_articles = {:articles => Article.of_column_for_ntt(108, 5), :id => 108} #专家活动
    @interview_articles = {:articles => Article.of_column_for_ntt(102, 5), :id => 102} #专家访谈
  end

  def show
    #slug patch for '叶壇' , By Vincent, 2012-02-02
    if params[:id] == "xie_tan"
      redirect_to ntt_columnist_url('ye_tan')
      return
    end
    
    @columnist = Columnist.where(:slug => params[:id]).first
    @columnist_articles = @columnist.articles.order("id DESC").includes(:pages => :image).page(params[:page])
  end
  
  private
  def ntt_authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
    end
  end
end
