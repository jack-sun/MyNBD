# encoding: utf-8
class ColumnsController < ApplicationController

  layout "site_v3"

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
  
  PARENT_COLUMNS_INDEX = {1 => :home, 6 => :news, 10 => :stock, 33 => :company, 47 => :global, 56 => :opinion, 61 => :life, 70 => :bschool, 119 => :finance, 129 => :auto, 226 => :shanghai}
  SUBDOMAIN_INDEX = PARENT_COLUMNS_INDEX.invert
  CURRRENT_NAV_SUBDOMAINS = {6 => :news, 10 => :stock, 33 => :company, 61 => :life, 70 => :bschool, 119 => :finance, 129 => :auto, 226 => :shanghai}
  
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
      if subdomain == "preview"
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
    if @column_id == Column::NTT_COLUMN_ID
      redirect_to Settings.ntt_host
      return
    end
    
    #Patch: redirect to subdomain request, Vincent, 2012-01-05
    ##### comment for preview by zhangbo, 2013-06-27
    # if CURRRENT_NAV_SUBDOMAINS.keys.include?(@column_id)
    #   redirect_to Helper.customize_host_url(CURRRENT_NAV_SUBDOMAINS[@column_id].to_s)
    #   return
    # end

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
        
      render :articles_list
    end
    
  end

  private
  
  def home_action
    #@hot_topics = {:topics => Topic.hot_topics(1), :id => 'hot_topic'} #社区热议
    #@stock_live = {:compere => User.stock_live_user, :id => 'stock_live', :live_talks => Live.last.live_talks.includes([:weibo => :owner, :live_answers => {:weibo => :owner}]).order("id desc").limit(2)} #股市直播
    unless fragment_exist?(Live::HOME_INDEX_FRAGMENT_KEY)
      @showed_live = Live.showed_lives(Rails.cache.read(Live::LIVE_SHOW_TYPE_KEY)||"1").order("id desc").first
      @showed_live_talks = @showed_live.live_talks.where(:talk_type => LiveTalk::TYPE_TALK).includes([:weibo => :owner, :live_answers => {:weibo => :owner}]).order("id desc").limit(2) #直播
    end
    @touzibao_latest_cases = Touzibao.latest_cases(3)
    
    #首页section
    @head_articles = {:articles => Article.of_column(2, 5), :id => 2} #首页头条
    @ntt_head_article = {:articles => Article.of_column_for_ntt(57, 1), :id => 57} #智库头条
    @rolling_articles = {:articles => Article.rolling.order("id DESC").limit(5), :id => 'rolling_news'} #滚动新闻
    @important_articles = {:articles => Article.of_column(3, 3), :id => 3} #要闻
    @important_articles_stock = {:articles => Article.of_column(11, 3), :id => 11} #要闻-股票
    @important_articles_company = {:articles => Article.of_column(34, 3), :id => 34} #要闻-公司
    @important_articles_finance = {:articles => Article.of_column(120, 3), :id => 120} #要闻-金融
    unless fragment_exist?(column_show_content_key_by_id(Column::NBD_ORIGINAL_COLUMN_ID))
      @original_articles = {:articles => Column.aggregate_articles(Column::ORIGINAL_COLUMNS, 3), :id => Column::NBD_ORIGINAL_COLUMN_ID}    #每经原创
    end

    @image_articles = {:articles => Article.of_column(4,5), :id => 4} #图片新闻

    @featured_articles = {:articles => Article.of_column(5,3), :id => 5} #每日精选
    @nbd_special_articles = {:articles => Article.of_column(81,1), :id => 81} #nbd特稿
    @bulletin_articles = {:articles => Article.of_column(118,1), :id => 118} #公告
    @ipo_articles = {:articles => Article.of_column(31, 1) ,:id => 31} #ipo调查

    @consumer_articles = {:articles => Article.of_column(82,1), :id => 82} #商业消费
    @yetan_update = {:articles => Article.of_column_for_ntt(89, 1), :id => 89 } #叶檀每日评
    @popular_features = {:articles => Article.of_column(183, 3), :id => 183 } #专题精选
    @nbd_west = {:articles => Article.of_column(196, 3), :id => 196} #西部精选
    
    #股票 section
    unless fragment_exist?(column_show_content_key_by_id(Column::HOME_COMBINED_COLUMN_ID))
      @market_collection = {:articles => Column.aggregate_articles([23, 24, 25, 26, 27, 28], 10), :id => 10}#市场综合
    end
    @market_express_articles = {:articles => Article.of_column(12, 10) ,:id => 12}#行情快讯
    @zhengbuchun_column = {:articles => Article.of_column(86, 3), :id => 86}#郑眼看盘
    @laofashi_column = {:articles => Article.of_column(85, 3), :id => 85}#老法师
    @analysis_articles = {:articles => Article.of_column(29, 5) ,:id =>29 }#对策
    @stock_bulletin = {:articles => Article.of_column(28, 5) ,:id =>28 }#对策
    #@market_column_articles = {:articles => Article.of_column(30, 2), :id => 30 }#专栏
    #@combined_articles = {:articles => Column.aggregate_articles([23, 24, 25, 26, 27, 28], 6), :id => Column::HOME_COMBINED_COLUMN_ID} #综合: 股票 ~ 大宗商品 (23 ~ 28). logic move to view
    @company_inv_articles = {:articles => Article.of_column(32, 3), :id => 32}#上市公司调查 （32）
    #@institution_articles = {:articles => Article.of_column(41, 5), :id => 41}#机构解盘

    #公司 section
    @finace_articles = {:articles => Article.of_column(35, 5), :id => 35}#热公司
    @property_articles = {:articles => Article.of_column(38, 5), :id => 38}#房产
    @sicence_articles = {:articles => Article.of_column(39, 5), :id => 39 }#科技
    @auto_articles = {:articles => Article.of_column(130, 5), :id => 130 }#汽车热点
    @business_information_articles = {:articles => Article.of_column(42, 5), :id => 42}#商讯
    @biz_featured_articles = {:articles => Article.of_column(36, 5), :id => 36}#商业精选
    @campaign_articles = {:articles => Article.of_column(84, 5), :id => 84} #活动会议
    #@biz_inv_articles = Column.find(77).articles.order("id DESC").limit(6)#调查    


    #全球 section
    @global_express_articles = {:articles => Article.of_column(48, 5), :id => 48 } #全球快讯
    @global_featured_articles = {:articles => Article.of_column(55, 5), :id => 55 } #全球精选
    @global_america = {:articles => Article.of_column(53, 5), :id => 53 } #美洲
    @global_asia = {:articles => Article.of_column(54, 5), :id => 54 } #亚洲
    @global_europe = {:articles => Article.of_column(51, 5), :id => 51 } #亚洲
    @macro = {:articles => Article.of_column(44, 5), :id => 44 }


    #智库 section
    @columnist_articles = {:id => 102, :articles => []}
    unless fragment_exist?(columnist_articles_key_by_id("index_table"))
      @columnists = Columnist.order("last_article_id desc").limit(10).includes([{:last_article => :columns}, :image]).select{|c| c.last_article and c.last_article.columns and !c.last_article.columns.map(&:id).include?(102)}[0..3]
      @columnists.each do |columnist|
        @columnist_articles[:articles] << columnist.articles.published.order('id DESC').first
      end
    end
    @interview_articles = {:articles => Article.of_column_for_ntt(102, 5), :id => 102} #专家访谈
    @ntt_books = {:articles => Article.of_column_for_ntt(117, 5), :id => 117} #每经书会
    @ntt_house_observe = {:articles => Article.of_column(184, 5), :id => 184 } #楼市观察
    @ntt_urbanization = {:articles => Article.of_column(211, 5), :id => 211 } #十字化的城镇路口
    @ntt_huaerjie_observe = {:articles => Article.of_column(208, 5), :id => 208} #说不完的华尔街
    #@opinion_column_articles = {:articles => Article.of_column(58, 5), :id => 58 }#专栏
    #@opinion_comment_articles = {:articles => Article.of_column(59, 5), :id => 59 }# 评论
    #@yetan_column = {:articles => Article.of_column(89, 5), :id => 89 }# 叶檀每日评
    #@note = {:articles => Article.of_column(60, 5), :id => 60 }  #记者手记
    
    #品味 section
    @entertainment_articles = {:articles => Article.of_column(63, 5), :id => 63 }#娱乐
    @fashion_articles = {:articles => Article.of_column(64, 5), :id => 64 }#时尚
    @life_travel = {:articles => Article.of_column(65, 5), :id => 65} #探索
    @life_taste = {:articles => Article.of_column(66, 5), :id => 66} #奢侈品
    
    #管理 section
    @career_articles = {:articles => Article.of_column(72, 5), :id => 72 }#职场
    @people_articles = {:articles => Article.of_column(73, 5), :id => 73}#人物
    @mba_articles = {:articles => Article.of_column(74, 5), :id => 74 }#商学院
    @bschool_featured = {:articles => Article.of_column(76, 5), :id => 76} #管理精选
    
    #其它 section
    @video_news = {:articles => Article.of_column(195, 4), :id => 195} #视听-每经财讯
    @video_face_to_face = {:articles => Article.of_column(194, 4), :id => 194} #视听-财经面对面
    @image_news = {:articles => Article.of_column(4, 4), :id => 4} #图片新闻
            
    render :home
  end
  
  def news_action

    @bulletin_articles = {:articles => Article.of_column(118,1), :id => 118} #公告
    
    @head_article = {:articles => Article.of_column(7, 3), :id => 7} #头条
    
    @rolling_articles = {:articles => Article.rolling.includes(:columns, {:pages => :image}).order("id DESC").page(params[:page]).per(10), :id => 'rolling_news'} #滚动新闻
    
    @featured_articles = {:articles => Article.of_column(9, 4), :id => 9} #每日精选
    
    @focus_articles = {:articles => Article.of_column(8, 10), :id => 8} #媒体聚焦
    
    # @market_express_articles = {:articles => Article.of_column(12, 10), :id => 12} #行情快讯

    @viewpoint_articles = {:articles => Article.of_column(258, 4), :id => 258} #财经视点
    
    @macro = {:articles => Article.of_column(44, 4), :id => 44 } #宏观要闻

    @image_articles = {:articles => Article.of_column(214, 5), :id => 214} #图片新闻

    @entertainment = {:articles => Article.of_column(187, 5), :id => 187} #时事要闻
    @world = {:articles => Article.of_column(188, 5), :id => 188} #热点精选
    @fun_story = {:articles => Article.of_column(190, 5), :id => 190} #社会纵横

    
    render :news
  end
  
  def stock_action
    
    @head_article = {:articles => Article.of_column(11, 5), :id => 11} #头条
    
    @individual_stock = {:articles => Article.of_column(23, 5), :id => 23} #个股
    
    @fund = {:articles => Article.of_column(24, 5), :id => 24} #基金
    
    @exchange = {:articles => Article.of_column(26, 10), :id => 26} #外汇
    
    @macro_stock = {:articles => Article.of_column(27, 5), :id => 27} #大盘
    
    @bulletin = {:articles => Article.of_column(28, 5), :id => 28} #公告
    
    @analysis = {:articles => Article.of_column(29, 10), :id => 29} #对策
    
    @hk_stock = {:articles => Article.of_column(30, 5), :id => 30} #港股
    
    @ipo_articles = {:articles => Article.of_column(31, 1) ,:id => 31} #ipo调查
    
    @company_inv_articles = {:articles => Article.of_column(32, 1), :id => 32} #上市公司调查
    
    @zhengbuchun_column = {:articles => Article.of_column(86, 1), :id => 86}#郑眼看盘
    
    @yetan_column = {:articles => Article.of_column(89, 5), :id => 89 }# 叶檀每日评
    
    @laofashi_column = {:articles => Article.of_column(85, 1), :id => 85}#老法师
    
    @market_express = {:articles => Article.of_column(12, 10) ,:id => 12}#行情快讯
    
    @finace = {:articles => Article.of_column(37, 5), :id => 37} #机构

    @image_articles = {:articles => Article.of_column(215, 5), :id => 215} #图片新闻
    
    render :stock
    
  end
  
  def company_action
    
    @head_article = {:articles => Article.of_column(34, 3), :id => 34} #头条

    @original_articles = {:articles => Column.aggregate_articles(Column::ORIGINAL_COLUMNS, 3), :id => Column::NBD_ORIGINAL_COLUMN_ID} #每经原创
    
    @hot = {:articles => Article.of_column(35, 10), :id => 35 } #热公司
    
    @property = {:articles => Article.of_column(38, 10), :id => 38} #房产
    
    @sicence = {:articles => Article.of_column(39, 10), :id => 39 } #科技
    
    @auto = {:articles => Article.of_column(40, 10), :id => 40 } #汽车
    
    @industry = {:articles => Article.of_column(42, 10), :id => 42 } #工业
    
    @macro = {:articles => Article.of_column(44, 5), :id => 44 } #宏观要闻
    
    @consumable = {:articles => Article.of_column(45, 10), :id => 45 } #消费品
    
    @featured = {:articles => Article.of_column(36, 4), :id => 36} #商业精选
    
    @ipo_articles = {:articles => Article.of_column(31, 1) ,:id => 31} #ipo调查
    
    @company_inv_articles = {:articles => Article.of_column(32, 1), :id => 32} #上市公司调查

    @image_articles = {:articles => Article.of_column(216, 5), :id => 216} #图片新闻
    
    render :company
  end
  
  
  def life_action
    
    @head_article = {:articles => Article.of_column(62, 3), :id => 62} #头条
    
    @entertainment = {:articles => Article.of_column(63, 6), :id => 63} #娱乐星闻
    
    @fashion = {:articles => Article.of_column(64, 5), :id => 64} #时尚新潮
    
    @taste = {:articles => Article.of_column(66, 5), :id => 66} #奢侈品
    
    @travel = {:articles => Article.of_column(65, 5), :id => 65} #大千世界
    
    @money = {:articles => Article.of_column(67, 5), :id => 67} #投资理财
    
    @book = {:articles => Article.of_column(68, 5), :id => 68} #读书求职
    
    @featured = {:articles => Article.of_column(69, 4), :id => 69} #生活精选
    
    @focus_articles = {:articles => Article.of_column(8, 5), :id => 8} #媒体聚焦
    
    @hot_topics = {:topics => Topic.hot_topics(1), :id => 'hot_topic'} #社区热议

    @image_articles = {:articles => Article.of_column(218, 5), :id => 218} #图片新闻
    
    render :life
  end
  
  def bschool_action
    @head_article = {:articles => Article.of_column(71, 3), :id => 71} #头条
    
    @career = {:articles => Article.of_column(72, 10), :id => 72} #职场
    
    @mba = {:articles => Article.of_column(74, 10), :id => 74} #商学院
    
    @people = {:articles => Article.of_column(73, 10), :id => 73} #人物
    
    @front = {:articles => Article.of_column(75, 10), :id => 75} #管理前沿
    
    @featured = {:articles => Article.of_column(76, 4), :id => 76} #管理精选

    @image_articles = {:articles => Article.of_column(219, 5), :id => 219} #图片新闻
    
    render :bschool
  end
  
  def finance_action
  
    @original_articles = {:articles => Column.aggregate_articles(Column::ORIGINAL_COLUMNS, 3), :id => Column::NBD_ORIGINAL_COLUMN_ID} #每经原创

    @head_article = {:articles => Article.of_column(120, 3), :id => 120} #头条
    
    @featured = {:articles => Article.of_column(121, 4), :id => 121} #精选
    
    @hot = {:articles => Article.of_column(139, 5), :id => 139} #热点
    
    @bank = {:articles => Article.of_column(122, 5), :id => 122} #银行
    
    @insurance = {:articles => Article.of_column(123, 5), :id => 123} #保险
    
    @exchange = {:articles => Article.of_column(124, 5), :id => 124} #外汇
    
    @fund = {:articles => Article.of_column(125, 5), :id => 125} #基金
    
    @bond = {:articles => Article.of_column(126, 5), :id => 126} #债券
    
    @financing = {:articles => Article.of_column(127, 5), :id => 127} #理财
    
    @bank_product = {:articles => Article.of_column(128, 5), :id => 128} #银行产品
    
    # Right Column
    
    @ipo_articles = {:articles => Article.of_column(31, 1), :id => 31} #ipo调查
    
    @company_inv_articles = {:articles => Article.of_column(32, 1), :id => 32} #上市公司调查
    
    @macro = {:articles => Article.of_column(44, 5), :id => 44 } #宏观要闻

    @image_articles = {:articles => Article.of_column(220, 5), :id => 220} #图片新闻
    
    render :finance
  end
  
  def auto_action
    @head_article = {:articles => Article.of_column(130, 5), :id => 130} #头条

    @hot = {:articles => Article.of_column(140, 8), :id => 140} #热点

    @hot_articles = Column.find(129).hot_articles[0..6]

    @new = {:articles => Article.of_column(132, 7), :id => 132} #新车

    @image_articles = {:articles => Article.of_column(222, 5), :id => 222 } #图片新闻

    @industry_company_articles = {:articles => Article.of_column(223, 7), :id => 223} #行业公司

    @featured = {:articles => Article.of_column(131, 4), :id => 131} #精选

    @people_articles = {:articles => Article.of_column(224, 5), :id => 224} #人物

    @viewpoint_articles = {:articles => Article.of_column(255, 5), :id => 255} #观点

    @vote_articles = {:articles => Article.of_column(225, 1), :id => 225} #互动投票

    @evaluation = {:articles => Article.of_column(134, 5), :id => 134} #测评
  
    @market = {:articles => Article.of_column(133, 5), :id => 133} #行情

    @shopping_guide = {:articles => Article.of_column(135, 5), :id => 135} #导购


  #-----------------END PREVIEW------------------
    
    # @hot = {:articles => Article.of_column(2, 10), :id => 2} #首页头条
        
    @bycar = {:articles => Article.of_column(136, 10), :id => 136} #自驾    Canel
    
    @security = {:articles => Article.of_column(137, 10), :id => 137} #安全   Canel
    
    @second_hand = {:articles => Article.of_column(138, 10), :id => 138} #二手车   Canel
    
    # Right Column
    
    @ipo_articles = {:articles => Article.of_column(31, 1), :id => 31} #ipo调查
    
    @company_inv_articles = {:articles => Article.of_column(32, 1), :id => 32} #上市公司调查
    
    @macro = {:articles => Article.of_column(44, 5), :id => 44 } #宏观要闻

    @zhuanti = {:articles => Article.of_column(260, 5), :id => 260 } #专题

    @yuanchuang = {:articles => Article.of_column(261, 5), :id => 261 } #原创

    render :auto
  end

  def global_action
    @head_article = {:articles => Article.of_column(226, 3), :id => 226 } # 头条    

    @express = {:articles => Article.of_column(48, 9), :id => 48 } # 全球快讯
    
    @us = {:articles => Article.of_column(49, 9), :id => 49 } #美国
    
    @featured = {:articles => Article.of_column(55, 4), :id => 55 } #全球精选
    
    @euro = {:articles => Article.of_column(51, 9), :id => 51 } #欧洲
    
    @asia = {:articles => Article.of_column(54, 9), :id => 54 } #亚洲
    
    @america = {:articles => Article.of_column(53, 9), :id => 53 } #美洲
    
    @others = {:articles => Article.of_column(87, 9), :id => 87 } #其它
    
    @focus_articles = {:articles => Article.of_column(8, 5), :id => 8} #媒体聚焦

    @image_articles = {:articles => Article.of_column(217,5), :id => 217} #图片新闻
    
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


  def shanghai_action
    @head_articles = {:articles => Article.of_column(227, 3), :id => 227}  #头条

    @area_dynamic_articles = {:articles => Article.of_column(228, 9), :id => 228}  #各区动态

    unless fragment_exist?(column_show_content_key_by_id(Column::SHANGHAI_COMPLEX_INFORMATION_COLUMN_ID))
      @complex_information_articles = {:name => "资讯", :articles => Column.aggregate_articles(Column::SHANGHAI_COMBINED_COLUMNS[Column::SHANGHAI_COMPLEX_INFORMATION_COLUMN_ID], 4), 
      :id => Column::SHANGHAI_COMPLEX_INFORMATION_COLUMN_ID, :sub_columns => Column.where("id in (?)", Column::SHANGHAI_COMBINED_COLUMNS[Column::SHANGHAI_COMPLEX_INFORMATION_COLUMN_ID])}   #综合_资讯
    end

    unless fragment_exist?(column_show_content_key_by_id(Column::SHANGHAI_COMPLEX_FASHION_COLUMN_ID))
      @complex_fashion_articles = {:name => "尚海", :articles => Column.aggregate_articles(Column::SHANGHAI_COMBINED_COLUMNS[Column::SHANGHAI_COMPLEX_FASHION_COLUMN_ID], 4), 
      :id => Column::SHANGHAI_COMPLEX_FASHION_COLUMN_ID, :sub_columns => Column.where("id in (?)", Column::SHANGHAI_COMBINED_COLUMNS[Column::SHANGHAI_COMPLEX_FASHION_COLUMN_ID])}   #综合_尚海
    end

    unless fragment_exist?(column_show_content_key_by_id(Column::SHANGHAI_COMPLEX_LIVE_COLUMN_ID))
      @complex_live_articles = {:name => "生活", :articles => Column.aggregate_articles(Column::SHANGHAI_COMBINED_COLUMNS[Column::SHANGHAI_COMPLEX_LIVE_COLUMN_ID], 4), 
      :id => Column::SHANGHAI_COMPLEX_LIVE_COLUMN_ID, :sub_columns => Column.where("id in (?)", Column::SHANGHAI_COMBINED_COLUMNS[Column::SHANGHAI_COMPLEX_LIVE_COLUMN_ID])}   #综合_生活
    end

    unless fragment_exist?(column_show_content_key_by_id(Column::SHANGHAI_COMPLEX_EDUCATION_COLUMN_ID))
      @complex_eduction_articles = {:name => "教育", :articles => Column.aggregate_articles(Column::SHANGHAI_COMBINED_COLUMNS[Column::SHANGHAI_COMPLEX_EDUCATION_COLUMN_ID], 4), 
      :id => Column::SHANGHAI_COMPLEX_EDUCATION_COLUMN_ID, :sub_columns => Column.where("id in (?)", Column::SHANGHAI_COMBINED_COLUMNS[Column::SHANGHAI_COMPLEX_EDUCATION_COLUMN_ID])}   #综合_教育
    end

    @delta_shanghai_articles = {:articles => Article.of_column(229, 8), :id => 229}  #长三角上海

    @delta_zhejiang_articles = {:articles => Article.of_column(230, 8), :id => 230}  #长三角浙江

    @delta_jiangsu_articles = {:articles => Article.of_column(231, 8), :id => 231}   #长三角江苏

    @meeting_articles = {:articles => Article.of_column(232, 3), :id => 232}    #会议论坛

    @show_articles = {:articles => Article.of_column(233, 3), :id => 233}   #展会

    @fashion_articles = {:articles => Article.of_column(234, 5), :id => 234}  #时尚

    @shopping_articles = {:articles => Article.of_column(235, 3), :id => 235}   #购物

    @movie_articles = {:articles => Article.of_column(236, 5), :id => 236}    #电影

    @drama_articles = {:articles => Article.of_column(251, 5), :id => 251}    #话剧

    @performing_arts_articles = {:articles => Article.of_column(237, 5), :id =>237}   #演艺

    @food_articles = {:articles => Article.of_column(238, 5), :id => 238}   #美食

    @health_articles = {:articles => Article.of_column(239, 5), :id => 239}   #健康

    @travel_articles = {:articles => Article.of_column(240, 5), :id => 240}   #旅游

    @happy_life_articles = {:articles => Article.of_column(241, 5), :id => 241}   #乐活

    @workplace_articles = {:articles => Article.of_column(242, 5), :id => 242}   #职场

    @train_articles = {:articles => Article.of_column(243, 5), :id => 243}    #培训

    @eduction_articles = {:articles => Article.of_column(254, 5), :id => 254}   #教育 视点

    @family_articles = {:articles => Article.of_column(244, 5), :id => 244}   #亲子

    @school_articles = {:articles => Article.of_column(245, 5), :id => 245}   #学校

    @abroad_articles = {:articles => Article.of_column(246, 5), :id => 246}   #出国

    @early_learning_articles = {}   #早教

    @show_field_articles = {:articles => Article.of_column(249, 3), :id => 249}   #秀场

    @sub_column_nav_fashion = Column.select([:id, :name]).where("id in (?)", [234, 235, 236, 237])   #二级导航_尚海

    @sub_column_nav_live = Column.select([:id, :name]).where("id in (?)", [238, 239, 240, 241])   #二级导航_生活

    @sub_column_nav_eduction = Column.select([:id, :name]).where("id in (?)", [242, 243, 244, 245, 246, 247])   #二级导航_教育

    @image_articles = {:articles => Article.of_column(248, 5), :id => 57} #图片新闻

    render :shanghai
  end

end
