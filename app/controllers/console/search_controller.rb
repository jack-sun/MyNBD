# encoding: utf-8
require 'nbd/utils'
class Console::SearchController < ApplicationController
  
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console
  
  def article_search
    @keyword = params[:q]

    @articles = Article.search(@keyword, :page => params[:page], :per_page => 10, :order => :id, :sort_mode => :desc, :include => [{:columns => :parent}, :staffs, :pages, :children_articles, :weibo])
  end
  
  def weibo_search
  end
  
  def user_search
  end
  
  def image_search
    @keyword = params[:q]
    
    @images = Image.search(@keyword, :page => params[:page], :per_page => 10, :order => :id, :sort_mode => :desc)
  end
  
end
