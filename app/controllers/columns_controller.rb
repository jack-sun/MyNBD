# encoding: utf-8
class ColumnsController < ApplicationController
  
  layout 'site'
  
  before_filter :current_user
  #before_filter :forbid_request_of_mobile_news, :only => [:show]
  before_filter :forbid_request_of_touzibao
  # after_filter :only => [:show] do |c|
  #   path = nbd_page_cache_path
  #   write = nil
  #   if params[:page]
  #     write = params[:page].to_i < 11
  #   else
  #     write = true
  #   end
    # if write and !File.exists?(path)
      # Resque.enqueue(Jobs::WritePageCache, response.body, path)
      # Resque.enqueue_in(Column::PAGE_CACHE_EXPIRE_TIME, Jobs::DeletePageCache, "column", path)
    # end
  # end
  
  PARENT_COLUMNS_INDEX = {1 => :home, 6 => :news, 10 => :stock, 33 => :company, 47 => :global, 56 => :opinion, 61 => :life, 70 => :bschool, 119 => :finance, 129 => :auto}
  SUBDOMAIN_INDEX = PARENT_COLUMNS_INDEX.invert
  CURRRENT_NAV_SUBDOMAINS = {6 => :news, 10 => :stock, 33 => :company, 61 => :life, 70 => :bschool, 119 => :finance, 129 => :auto}
  
  class Helper
    class << self
      #include Singleton - no need to do this, class objects are singletons
      include ApplicationHelper
      include ActionView::Helpers::TextHelper
      include ActionView::Helpers::UrlHelper
      include ApplicationHelper
    end
  end
  
  def show
    #@global_hot_articles = Article.hot_articles(20)[0..9] #temp solution, Vincent 2011-12-05
    #@global_hot_comment_articles = Article.hot_comment_articles(20)[0..9] #temp solution, Vincent 2011-12-05

    if (current_column_id = params[:id].to_i) == 1
      subdomain = request.subdomain(Settings.domain_length.to_i)
      logger.debug "---------------subdomain: #{subdomain}"
      if subdomain == "www"
        @column_id = params[:id].to_i
        return send("home_action")
      else
        @column_id = SUBDOMAIN_INDEX[subdomain.to_sym]
        
        logger.debug "------------@column_id: #{@column_id}"
        logger.debug "------------params[:id]: #{params[:id]}"
        return send("#{subdomain}_action")
      end
    end
    @column_id = params[:id].to_i
    
    # redirect to ntt host. update by Vincent. 2012-01-31
    if @column_id == 56
      redirect_to Settings.ntt_host
      return
    end
    
    #Patch: redirect to subdomain request, Vincent, 2012-01-05
    if CURRRENT_NAV_SUBDOMAINS.keys.include?(@column_id)
      redirect_to Helper.customize_host_url(CURRRENT_NAV_SUBDOMAINS[@column_id].to_s)
      return
    end

    if PARENT_COLUMNS_INDEX.keys.include?(@column_id)
      send("#{PARENT_COLUMNS_INDEX[@column_id]}_action")
    else
      @column = Column.find(@column_id)
      @articles_columns = Article.of_child_column(@column_id).page(params[:page]).per(15)

      if @column_id == Column::MOBILE_NEWS_COLUMN
        #@articles_columns = @articles_columns.where(["created_at < ?", Time.now.beginning_of_day])
        @articles_columns = @articles_columns.offset(1)
      end
      
      #TODO
      #@global_hot_articles = Article.hot_articles(20)[0..9] #temp solution, Vincent 2011-12-05
      #@global_hot_comment_articles = Article.hot_comment_articles(20)[0..9] #temp solution, Vincent 2011-12-05
      
      temp_column_id = @column.parent_id.nil? ? @column.id : @column.parent_id
      temp_column_id = Column::FEATURE_COLUMN_HASH[temp_column_id]
      @featured_articles = {:articles => Article.of_column(temp_column_id, 4), :id => temp_column_id} #频道精选
      
      @focus_articles = {:articles => Article.of_column(8, 5), :id => 8} #媒体聚焦
        
      render :action => :articles_list
    end
    
    
  end
  
  def articles_list
  end
  
  private
  
  def home_action
    #@hot_topics = {:topics => Topic.hot_topics(1), :id => 'hot_topic'} #社区热议
    #@stock_live = {:compere => User.stock_live_user, :id => 'stock_live', :live_talks => Live.last.live_talks.includes([:weibo => :owner, :live_answers => {:weibo => :owner}]).order("id desc").limit(2)} #股市直播
    @showed_live = Live.showed_lives(Rails.cache.read(Live::LIVE_SHOW_TYPE_KEY)||"1").order("id desc").first
    @showed_live_talks = @showed_live.live_talks.where(:talk_type => LiveTalk::TYPE_TALK).includes([:weibo => :owner, :live_answers => {:weibo => :owner}]).order("id desc").limit(2) #直播
    @touzibao_latest_cases = Touzibao.latest_cases(3)
    
    #首页section
    @head_article = {:articles => Article.of_column(2, 3), :id => 2} #首页头条
    @ntt_head_article = {:articles => Article.of_column_for_ntt(57, 2), :id => 57} #智库头条
    @rolling_articles = {:articles => Article.rolling.order("id DESC").limit(5), :id => 'rolling_news'} #滚动新闻
    @important_articles = {:articles => Article.of_column(3, 6), :id => 3} #要闻
    @image_articles = {:articles => Article.of_column(4,3), :id => 4} #图片新闻
    @featured_articles = {:articles => Article.of_column(5,4), :id => 5} #每日精选
    @nbd_special_articles = {:articles => Article.of_column(81,1), :id => 81}#nbd特稿
    @bulletin_articles = {:articles => Article.of_column(118,1), :id => 118}#nbd特稿
    @ipo_articles = {:articles => Article.of_column(31, 1) ,:id => 31}#ipo调查 (31)
    @consumer_articles = {:articles => Article.of_column(82,1), :id => 82}#商业消费
    @yetan_update = {:articles => Article.of_column_for_ntt(89, 1), :id => 89 }# 叶檀每日评
    @popular_features = {:articles => Article.of_column(183, 1), :id => 183 } #专题精选
    @nbd_west = {:articles => Article.of_column(196, 3), :id => 196} #西部精选
    
    
    #股票 section
    @market_express_articles = {:articles => Article.of_column(12, 10) ,:id => 12}#行情快讯
    @zhengbuchun_column = {:articles => Article.of_column(86, 5), :id => 86}#郑眼看盘
    @laofashi_column = {:articles => Article.of_column(85, 5), :id => 85}#老法师
    @analysis_articles = {:articles => Article.of_column(29, 4) ,:id =>29 }#对策
    #@market_column_articles = {:articles => Article.of_column(30, 2), :id => 30 }#专栏
    #@combined_articles = {:articles => Column.aggregate_articles([23, 24, 25, 26, 27, 28], 6), :id => Column::HOME_COMBINED_COLUMN_ID} #综合: 股票 ~ 大宗商品 (23 ~ 28). logic move to view
    @company_inv_articles = {:articles => Article.of_column(32, 1), :id => 32}#上市公司调查 （32）
    #@institution_articles = {:articles => Article.of_column(41, 5), :id => 41}#机构解盘
    
    #公司 section
    @finace_articles = {:articles => Article.of_column(35, 7), :id => 35}#热公司
    @property_articles = {:articles => Article.of_column(38, 7), :id => 38}#房产
    @sicence_articles = {:articles => Article.of_column(39, 7), :id => 39 }#科技
    @auto_articles = {:articles => Article.of_column(140, 7), :id => 140 }#汽车热点
    @biz_featured_articles = {:articles => Article.of_column(36, 1), :id => 36}#精选
    @campaign_articles = {:articles => Article.of_column(84, 4), :id => 84} #活动会议
    #@biz_inv_articles = Column.find(77).articles.order("id DESC").limit(6)#调查    
    
    #全球 section
    @global_express_articles = {:articles => Article.of_column(48, 5), :id => 48 }#全球快讯
    @global_featured_articles = {:articles => Article.of_column(55, 5), :id => 55 }#全球精选
    @macro = {:articles => Article.of_column(44, 5), :id => 44 }
    
    #智库 section
    @columnists = Columnist.order("last_article_id desc").limit(10).includes([{:last_article => :columns}, :image])
    @interview_articles = {:articles => Article.of_column_for_ntt(102, 2), :id => 102} #专家访谈
    #@opinion_column_articles = {:articles => Article.of_column(58, 5), :id => 58 }#专栏
    #@opinion_comment_articles = {:articles => Article.of_column(59, 5), :id => 59 }# 评论
    #@yetan_column = {:articles => Article.of_column(89, 5), :id => 89 }# 叶檀每日评
    #@note = {:articles => Article.of_column(60, 5), :id => 60 }  #记者手记
    
    #品味 section
    @entertainment_articles = {:articles => Article.of_column(63, 5), :id => 63 }#娱乐
    @fashion_articles = {:articles => Article.of_column(64, 5), :id => 64 }#时尚
    @travle_articles = {:articles => Article.of_column(65, 5), :id => 65 }#旅行
    
    #管理 section
    @career_articles = {:articles => Article.of_column(72, 5), :id => 72 }#职场
    @people_articles = {:articles => Article.of_column(73, 5), :id => 73}#人物
    @mba_articles = {:articles => Article.of_column(74, 5), :id => 74 }#商学院
    
    
    @video_news = {:articles => Article.of_column(195, 4), :id => 195} #视听-每经财讯
    
    @video_face_to_face = {:articles => Article.of_column(194, 4), :id => 194} #视听-财经面对面
    
    @image_news = {:articles => Article.of_column(4, 4), :id => 4} #图片新闻
            
    render :home
  end
  
  def news_action
    
    @head_article = {:articles => Article.of_column(7, 3), :id => 7} #头条
    
    @rolling_articles = {:articles => Article.rolling.includes(:columns, {:pages => :image}).order("id DESC").page(params[:page]).per(20), :id => 'rolling_news'} #滚动新闻
    
    @featured_articles = {:articles => Article.of_column(9, 4), :id => 9} #每日精选
    
    @focus_articles = {:articles => Article.of_column(8, 5), :id => 8} #媒体聚焦
    
    @market_express_articles = {:articles => Article.of_column(12, 9), :id => 12} #行情快讯
    
    @macro = {:articles => Article.of_column(44, 5), :id => 44 } #宏观要闻
    
    render :news
  end
  
  def stock_action
    
    @head_article = {:articles => Article.of_column(11, 3), :id => 11} #头条
    
    @individual_stock = {:articles => Article.of_column(23, 10), :id => 23} #个股
    
    @fund = {:articles => Article.of_column(24, 10), :id => 24} #基金
    
    @exchange = {:articles => Article.of_column(26, 10), :id => 26} #外汇
    
    @macro_stock = {:articles => Article.of_column(27, 10), :id => 27} #大盘
    
    @bulletin = {:articles => Article.of_column(28, 10), :id => 28} #公告
    
    @analysis = {:articles => Article.of_column(29, 10), :id => 29} #对策
    
    @hk_stock = {:articles => Article.of_column(30, 5), :id => 30} #港股
    
    @ipo_articles = {:articles => Article.of_column(31, 1) ,:id => 31} #ipo调查
    
    @company_inv_articles = {:articles => Article.of_column(32, 1), :id => 32} #上市公司调查
    
    @zhengbuchun_column = {:articles => Article.of_column(86, 5), :id => 86}#郑眼看盘
    
    @yetan_column = {:articles => Article.of_column(89, 5), :id => 89 }# 叶檀每日评
    
    @laofashi_column = {:articles => Article.of_column(85, 4), :id => 85}#老法师
    
    @market_express = {:articles => Article.of_column(12, 10) ,:id => 12}#行情快讯
    
    @finace = {:articles => Article.of_column(37, 10), :id => 37} #金融
    
    render :stock
    
  end
  
  def company_action
    
    @head_article = {:articles => Article.of_column(34, 3), :id => 34} #头条
    
    @hot = {:articles => Article.of_column(35, 10), :id => 35 } #热点
    
    @property = {:articles => Article.of_column(38, 10), :id => 38} #房产
    
    @sicence = {:articles => Article.of_column(39, 10), :id => 39 } #科技
    
    @auto = {:articles => Article.of_column(40, 10), :id => 40 } #汽车
    
    @industry = {:articles => Article.of_column(42, 10), :id => 42 } #工业
    
    @macro = {:articles => Article.of_column(44, 5), :id => 44 } #宏观要闻
    
    @consumable = {:articles => Article.of_column(45, 10), :id => 45 } #消费品
    
    @featured = {:articles => Article.of_column(36, 4), :id => 36} #商业精选
    
    @ipo_articles = {:articles => Article.of_column(31, 1) ,:id => 31} #ipo调查
    
    @company_inv_articles = {:articles => Article.of_column(32, 1), :id => 32} #上市公司调查
    
    render :company
  end
  
  def global_action
    
    @express = {:articles => Article.of_column(48, 10), :id => 48 } # 全球快讯
    
    @featured = {:articles => Article.of_column(55, 4), :id => 55 } #全球精选
    
    @us = {:articles => Article.of_column(49, 10), :id => 49 } #美国
    
    @euro = {:articles => Article.of_column(51, 10), :id => 51 } #欧洲
    
    @america = {:articles => Article.of_column(53, 10), :id => 53 } #美洲
    
    @asia = {:articles => Article.of_column(54, 10), :id => 54 } #亚洲
    
    @others = {:articles => Article.of_column(87, 10), :id => 87 } #亚洲
    
    @focus_articles = {:articles => Article.of_column(8, 5), :id => 8} #媒体聚焦
    
    render :global
  end
  
  def opinion_action
    
    @head_article = {:articles => Article.of_column(57, 3), :id => 57} #头条
    
    @column = {:articles => Article.of_column(58, 10), :id => 58 }#专栏
    
    @comment = {:articles => Article.of_column(59, 10), :id => 59 }# 评论
    
    @blog = {:articles => Article.of_column(88, 10), :id => 88 }# 博客
    
    @yetan_column = {:articles => Article.of_column(89, 5), :id => 89 }# 叶檀每日评
    
    @note = {:articles => Article.of_column(60, 10), :id => 60 }  #记者手记
    
    @nbd_weekly_comment = {:articles => Article.of_column(100, 1), :id => 100} #每经一周评
    
    render :opinion
  end
  
  def life_action
    
    @head_article = {:articles => Article.of_column(62, 3), :id => 62} #头条
    
    @entertainment = {:articles => Article.of_column(63, 10), :id => 63} #娱乐
    
    @fashion = {:articles => Article.of_column(64, 10), :id => 64} #时尚
    
    @travel = {:articles => Article.of_column(65, 10), :id => 65} #旅行
    
    @taste = {:articles => Article.of_column(66, 10), :id => 66} #品味
    
    @money = {:articles => Article.of_column(67, 10), :id => 67} #理财
    
    @book = {:articles => Article.of_column(68, 10), :id => 68} #读书
    
    @featured = {:articles => Article.of_column(69, 4), :id => 69} #生活精选
    
    @focus_articles = {:articles => Article.of_column(8, 5), :id => 8} #媒体聚焦
    
    @hot_topics = {:topics => Topic.hot_topics(1), :id => 'hot_topic'} #社区热议
    
    render :life
  end
  
  def bschool_action
    @head_article = {:articles => Article.of_column(71, 3), :id => 71} #头条
    
    @career = {:articles => Article.of_column(72, 10), :id => 72} #职场
    
    @people = {:articles => Article.of_column(73, 10), :id => 73} #人物
    
    @mba = {:articles => Article.of_column(74, 10), :id => 74} #商学院
    
    @front = {:articles => Article.of_column(75, 10), :id => 75} #管理前沿
    
    @featured = {:articles => Article.of_column(76, 4), :id => 76} #管理精选
    
    render :bschool
  end
  
  def finance_action
  
    @head_article = {:articles => Article.of_column(120, 3), :id => 120} #头条
    
    @featured = {:articles => Article.of_column(121, 4), :id => 121} #精选
    
    @hot = {:articles => Article.of_column(139, 10), :id => 139} #热点
    
    @bank = {:articles => Article.of_column(122, 10), :id => 122} #银行
    
    @insurance = {:articles => Article.of_column(123, 10), :id => 123} #保险
    
    @exchange = {:articles => Article.of_column(124, 10), :id => 124} #外汇
    
    @fund = {:articles => Article.of_column(125, 10), :id => 125} #基金
    
    @bond = {:articles => Article.of_column(126, 10), :id => 126} #债券
    
    @financing = {:articles => Article.of_column(127, 10), :id => 127} #理财
    
    @bank_product = {:articles => Article.of_column(128, 10), :id => 128} #银行产品
    
    # Right Column
    
    @ipo_articles = {:articles => Article.of_column(31, 1), :id => 31} #ipo调查
    
    @company_inv_articles = {:articles => Article.of_column(32, 1), :id => 32} #上市公司调查
    
    @macro = {:articles => Article.of_column(44, 5), :id => 44 } #宏观要闻
    
    render :finance
  end
  
  def auto_action
  
    @head_article = {:articles => Article.of_column(130, 3), :id => 130} #头条
    
    @featured = {:articles => Article.of_column(131, 4), :id => 131} #精选
    
    @hot = {:articles => Article.of_column(140, 10), :id => 140} #热点
    
    @new = {:articles => Article.of_column(132, 10), :id => 132} #新车
    
    @market = {:articles => Article.of_column(133, 10), :id => 133} #行情
    
    @evaluation = {:articles => Article.of_column(134, 10), :id => 134} #测评
    
    @shopping_guide = {:articles => Article.of_column(135, 10), :id => 135} #导购
    
    @bycar = {:articles => Article.of_column(136, 10), :id => 136} #自驾
    
    @security = {:articles => Article.of_column(137, 10), :id => 137} #安全
    
    @second_hand = {:articles => Article.of_column(138, 10), :id => 138} #二手车
    
    # Right Column
    
    @ipo_articles = {:articles => Article.of_column(31, 1), :id => 31} #ipo调查
    
    @company_inv_articles = {:articles => Article.of_column(32, 1), :id => 32} #上市公司调查
    
    @macro = {:articles => Article.of_column(44, 5), :id => 44 } #宏观要闻
    
    render :auto
  end
  
end
