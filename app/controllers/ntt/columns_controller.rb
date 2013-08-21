#encoding:utf-8
class Ntt::ColumnsController < ApplicationController

  USER_NAME = "nbdthinktank"
  PASSWORD = "socialntt"
  #before_filter :ntt_authenticate 
  
  layout "think_tank"
  #before_filter :authorize, :only => [:show]

  before_filter :forbid_request_of_touzibao, :only => [:show]
  before_filter :forbid_request_of_mobile_news, :only => [:show]
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

  COLUMNS_INDEX = {111 => "investment", 110 => "data", 109 => "report"}

  def index
    @feature_2013 = {:articles => Article.of_column(209, 1), :id => 209 }  #2013中国经济展望
    @editor_selected = {:articles => Article.of_column_for_ntt(116, 5), :id => 116} #编辑推荐
    @columnists = Columnist.order("last_article_id desc").limit(10).includes([{:last_article => :columns}, :image])
    @head_article = {:articles => Article.of_column_for_ntt(57, 1), :id => 57} #头条
    @newest_columnists = Columnist.order("id desc").limit(3).includes(:image) #最新加入
    #@ntt_features = {:articles => Article.of_column_for_ntt(113, 3), :id => 113} #精选专题
    @interview_articles = {:articles => Article.of_column_for_ntt(102, 2), :id => 102} #专家访谈
    @trend_articles = {:articles => Article.of_column_for_ntt(103, 5), :id => 103} #经济大势
    @region_articles = {:articles => Article.of_column_for_ntt(104, 5), :id => 104} #区域经济
    @global_articles = {:articles => Article.of_column_for_ntt(112, 5), :id => 112} #全球经济
    @comment_articles = {:articles => Article.of_column_for_ntt(105, 5), :id => 105} #商业评论
    @investment_articles = {:articles => Article.of_column_for_ntt(106, 5), :id => 106} #投资策略
    @management_articles = {:articles => Article.of_column_for_ntt(107, 5), :id => 107} #公共治理
    @activities_articles = {:articles => Article.of_column_for_ntt(108, 5), :id => 108} #每经公告
    #@nbd_weekly_comment = {:articles => ArticlesColumn.where(:id => 100).order("id desc").first.try(:article), :id => 100} #每经一周评
    @reporter_notes = {:articles => Article.of_column(60, 5), :id => 60 }  #记者手记
    @books = {:articles => Article.of_column_for_ntt(117, 2), :id => 117} #每经书会
    
    @tech_articles = {:articles => Article.of_column_for_ntt(256, 5), :id => 256} #科技前沿
    @life_articles = {:articles => Article.of_column_for_ntt(257, 5), :id => 257} #财富生活

    # features
    #@feature_2012 = {:articles => Article.of_column(113, 1), :id => 113 }  #2012中国经济展望
    #@feature_taiwan = {:articles => Article.of_column(114, 1), :id => 114 }  #走读台湾
    #@feature_wall_street = {:articles => Article.of_column(173, 1), :id => 173 }  #靓眼看华尔街
    #@double_meeting = {:articles => Article.of_column(143, 1), :id => 143 }  #两会
    #@china_reform = {:articles => Article.of_column(144, 1), :id => 144 }  #改革方向论
    #@feature_southAsia = {:articles => Article.of_column(115, 1), :id => 115 }  #南亚投资观察
    
    @house_observe = {:articles => Article.of_column(184, 1), :id => 184 }  #楼市观察
    @internet_observe = {:articles => Article.of_column(182, 1), :id => 182 }  #互联网观察
    @urbanization = {:articles => Article.of_column(211, 1), :id => 211 }  #互联网观察

    #@feature_southAsia = {:articles => Article.of_column(115, 1), :id => 115 }  #南亚投资观察
    #@reform_logic = {:articles => Article.of_column(174, 1), :id => 174 } #转型的逻辑
    @huaerjie_observe = {:articles => Article.of_column(208, 1), :id => 208}

    @all_columnists = Columnist.select([:id, :name, :slug])

    @one_word_articles_id = 100

  end

  def show
    @column_id = params[:id].to_i
    if COLUMNS_INDEX.keys.include?(@column_id)
      @is_premium_user = @current_user.present? ? @current_user.is_premium_user? : false
    else
      @is_premium_user = true
    end
    @column = Column.find(@column_id)
    @articles_columns = Article.of_child_column_for_ntt(@column_id).page(params[:page]).per(15)

    if params[:type] == 'feature'  
    	return render :action => "feature_articles_list"
    elsif @column_id == 109 #研究报告 
      @zhongbang_articles = {:articles => Article.of_column_for_ntt(201, 3), :id => 201} #重磅推荐
      @chenghui_articles = {:articles => Article.of_column_for_ntt(202, 5), :id => 202} #晨会速递
      @yanbao_articles = {:articles => Article.of_column_for_ntt(203, 4), :id => 203} #热门研报
      @led_articles = {:articles => Article.of_column_for_ntt(204, 5), :id => 204} #LED
      @wulian_articles = {:articles => Article.of_column_for_ntt(205, 5), :id => 205} #物联网
      @fantai_articles = {:articles => Article.of_column_for_ntt(206, 5), :id => 206} #钒钛
      @nengyuan_articles = {:articles => Article.of_column_for_ntt(207, 5), :id => 207} #新能源

      return render "report"
    else
    	return render :action => "articles_list"
    end
  end

  def features
    @feature_2012 = {:articles => Article.of_column(113, 5), :id => 113 }  #2012中国经济展望
    @feature_2013 = {:articles => Article.of_column(209, 5), :id => 209 }  #2013中国经济展望

    @feature_taiwan = {:articles => Article.of_column(114, 5), :id => 114 }  #走读台湾

    @feature_wall_street = {:articles => Article.of_column(173, 5), :id => 173 }  #靓眼看华尔街
        
    @double_meeting = {:articles => Article.of_column(143, 5), :id => 143 }  #两会

    @reform_logic = {:articles => Article.of_column(174, 5), :id => 174 } #转型的逻辑
        
    @china_reform = {:articles => Article.of_column(144, 5), :id => 144 }  #改革方向论
        
    @house_observe = {:articles => Article.of_column(184, 5), :id => 184 }  #楼市观察
        
    @internet_observe = {:articles => Article.of_column(182, 5), :id => 182 }  #互联网观察
        
    @feature_southAsia = {:articles => Article.of_column(115, 5), :id => 115 }  #南亚投资观察
  end
  
  def about
    @newest_columnists = Columnist.order("id desc").limit(3).includes(:image) #最新加入
  end
  
  private
  def ntt_authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
    end
  end
end
