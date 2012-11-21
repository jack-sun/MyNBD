#encoding:utf-8
class West::ColumnsController < ApplicationController

  layout "western"
  before_filter :forbid_request_of_mobile_news, :only => [:show]

  before_filter :forbid_request_of_touzibao, :only => [:show]
  after_filter :only => [:show, :index] do |c|
    path = nbd_page_cache_path
    write = nil
    if params[:page]
      write = params[:page].to_i < 11
    else
      write = true
    end
    if write and !File.exists?(path)
      Resque.enqueue(Jobs::WritePageCache, response.body, path)
      Resque.enqueue_in(Column::PAGE_CACHE_EXPIRE_TIME, Jobs::DeletePageCache, "column", path)
    end
  end

  COLUMNS_INDEX = {111 => "investment", 110 => "data", 109 => "report"}

  def index
    #第一屏
    @head_arrticles = {:articles => Article.of_column_for_ntt(146, 5), :id => 146} #头条
    @important_articles = {:articles => Article.of_column_for_ntt(147, 4), :id => 147} #要闻
    @image_articles = {:articles => Article.of_column_for_ntt(148, 3), :id => 148} #图片新闻
    @interview_articles = {:articles => Article.of_column_for_ntt(149, 5), :id => 149} #每经访谈
    @feature_articles = {:articles => Article.of_column_for_ntt(150, 5), :id => 150} # 专题策划
    @region_articles = {:articles => Article.of_column_for_ntt(104, 3), :id => 104} #区域经济
    
    #区域
    @sc_articles = {:articles => Article.of_column_for_ntt(151, 5), :id => 151} #四川
    @cq_articles = {:articles => Article.of_column_for_ntt(152, 5), :id => 152} #重庆
    @sx_articles = {:articles => Article.of_column_for_ntt(153, 5), :id => 153} #陕西
    @yn_articles = {:articles => Article.of_column_for_ntt(154, 5), :id => 154} #云南
    @gz_articles = {:articles => Article.of_column_for_ntt(155, 5), :id => 155} #贵州
    @lj_articles = {:articles => Article.of_column_for_ntt(156, 6), :id => 156} #两江新区
    @tf_articles = {:articles => Article.of_column_for_ntt(157, 6), :id => 157} #天府新区
    @xx_articles = {:articles => Article.of_column_for_ntt(158, 6), :id => 158} #西咸新区
    @yuanqu_articles = {:articles => Article.of_column_for_ntt(159, 5), :id => 159} #工业园区
    @xm_articles = {:articles => Article.of_column_for_ntt(160, 3), :id => 160} #招商项目
    @jzl_articles = {:articles => Article.of_column_for_ntt(161, 3), :id => 161} #竞争力
    
    #行业
    @jr_articles = {:articles => Article.of_column_for_ntt(162, 5), :id => 162} #金融
    @dc_articles = {:articles => Article.of_column_for_ntt(163, 5), :id => 163} #地产
    @gs_articles = {:articles => Article.of_column_for_ntt(164, 5), :id => 164} #公司
    @ny_articles = {:articles => Article.of_column_for_ntt(165, 5), :id => 165} #能源
    @qc_articles = {:articles => Article.of_column_for_ntt(166, 5), :id => 166} #汽车
    @sy_articles = {:articles => Article.of_column_for_ntt(167, 5), :id => 167} #商业
    @kx_articles = {:articles => Article.of_column_for_ntt(168, 5), :id => 168} #快消
    @it_articles = {:articles => Article.of_column_for_ntt(169, 5), :id => 169} #IT
    @hy_articles = {:articles => Article.of_column_for_ntt(170, 5), :id => 170} #商务会议
    @lx_articles = {:articles => Article.of_column_for_ntt(171, 5), :id => 171} #商务旅行
  end

  def show
    @column_id = params[:id].to_i
    @column = Column.find(@column_id)
    @articles_columns = Article.of_child_column_for_ntt(@column_id).page(params[:page]).per(15)

   render :action => "articles_list"
   return
  end

end
