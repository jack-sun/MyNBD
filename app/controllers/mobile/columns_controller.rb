# encoding: utf-8
class Mobile::ColumnsController < ApplicationController

  layout 'mobile'
  
  before_filter :current_user
  
  # after_filter :only => [:show] do |c|
  #   path = nbd_page_cache_path
  #   write = nil
  #   if params[:page]
  #     write = params[:page].to_i < 11
  #   else
  #     write = true
  #   end
  #   if write and !File.exists?(path)
  #     Resque.enqueue(Jobs::WritePageCache, response.body, path)
  #     Resque.enqueue_in(Column::PAGE_CACHE_EXPIRE_TIME, Jobs::DeletePageCache, "column", path)
  #   end
  # end
  PARENT_COLUMNS_INDEX = {1 => :home, 6 => :news, 10 => :market, 33 => :biz, 56 => :opinion}
  
  def show
    
    @column_id = params[:id].to_i
    #@global_hot_articles = Article.hot_articles(20)[0..9] #temp solution, Vincent 2011-12-05
    #@global_hot_comment_articles = Article.hot_comment_articles(20)[0..9]
    
    if PARENT_COLUMNS_INDEX.keys.include?(@column_id)
      send("#{PARENT_COLUMNS_INDEX[@column_id]}_action")
    else
      @column = Column.find(@column_id)
      @articles_columns = {:articles => Article.of_column(@column_id, 20), :id => @column_id}
      
      render :action => :articles_list
    end
    
  end
  
  def articles_list
  end

  private
  

  def home_action
    
    #首页section
    @head_article = {:articles => Article.of_column(2, 3), :id => 2}
    
    @rolling_articles = {:articles => Article.rolling.order("id DESC").limit(5), :id => 'rolling_news'} #滚动新闻
    
    @important_articles = {:articles => Article.of_column(3, 5), :id => 3} #要闻
    
    @macro = {:articles => Article.of_column(44, 5), :id => 44 } #宏观要闻
    
    @yetan_update = {:articles => Article.of_column(89, 3), :id => 89 }# 叶檀每日评
    
    #股票 section
    @market_express_articles = {:articles => Article.of_column(12, 5) ,:id => 12}#行情快讯
    
    @zhengbuchun_column = {:articles => Article.of_column(86, 3), :id => 86}#郑眼看盘
    
    @laofashi_column = {:articles => Article.of_column(85, 3), :id => 85}#老法师
    
    #公司 section
    @finace_articles = {:articles => Article.of_column(35, 5), :id => 35}#热公司
 
    
    render :home
  end
  
  def news_action
  
    @head_article = {:articles => Article.of_column(7, 3), :id => 7} #头条
    
    @rolling_articles = {:articles => Article.rolling.includes(:columns, {:pages => :image}).order("id DESC").page(params[:page]).per(10), :id => 'rolling_news'} #滚动新闻
    
    @featured_articles = {:articles => Article.of_column(9, 5), :id => 9} #每日精选
    
    render :news
    
  end
  
  def market_action
  
    @head_article = {:articles => Article.of_column(11, 3), :id => 11} #头条
    
    @macro_stock = {:articles => Article.of_column(27, 5), :id => 27} #大盘
    
    @analysis = {:articles => Article.of_column(29, 5), :id => 29} #对策

    @ipo_articles = {:articles => Article.of_column(31, 3) ,:id => 31} #ipo调查
    
    @company_inv_articles = {:articles => Article.of_column(32, 3), :id => 32} #上市公司调查
    
    @zhengbuchun_column = {:articles => Article.of_column(86, 5), :id => 86}#郑眼看盘
    
    @laofashi_column = {:articles => Article.of_column(85, 5), :id => 85}#老法师
    
    @market_express = {:articles => Article.of_column(12, 10) ,:id => 12}#行情快讯
    
    @finace = {:articles => Article.of_column(37, 5), :id => 37} #金融
    
    render :market
    
  end
  
  def biz_action
  
     @head_article = {:articles => Article.of_column(34, 3), :id => 34} #头条
     
     @hot = {:articles => Article.of_column(35, 5), :id => 35 } #热点
          
     @property = {:articles => Article.of_column(38, 5), :id => 38} #房产
     
     @sicence = {:articles => Article.of_column(39, 5), :id => 39 } #科技
     
     @auto = {:articles => Article.of_column(40, 5), :id => 40 } #汽车
     
     @consumable = {:articles => Article.of_column(45, 5), :id => 45 } #消费品
     
     @featured = {:articles => Article.of_column(36, 5), :id => 36} #商业精选

    render :biz
  end
  
  def opinion_action
  
    @head_article = {:articles => Article.of_column(57, 3), :id => 57} #头条
    
    @column = {:articles => Article.of_column(58, 5), :id => 58 }#专栏
    
    @comment = {:articles => Article.of_column(59, 5), :id => 59 }# 评论
    
    @note = {:articles => Article.of_column(60, 5), :id => 60 }  #记者手记
    
    @blog = {:articles => Article.of_column(88, 5), :id => 88 }# 博客
    
    @yetan_column = {:articles => Article.of_column(89, 3), :id => 89 }# 叶檀每日评
    
    render :opinion
  end
  
end
