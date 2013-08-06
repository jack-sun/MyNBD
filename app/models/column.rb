# encoding: utf-8
class Column < ActiveRecord::Base
  COLUMN_USERS = {}
  
  include Redis::Objects
  set :page_cache_file_names

  ROOT = 1
  HOME_COMBINED_COLUMN_ID = 10001
  MARKET_COMBINED_COLUMN_ID = 10002
  RSS_NEWEST_COLUMN_ID = 10003
  RSS_STOCK_INVEST_COLUMN_ID = 10004
  RSS_COMPANY_COLUMN_ID = 10005
  RSS_FINACE_COLUMN_ID = 10006
  RSS_DAILY_HEADLINE_COLUMN_ID = 10007
  RSS_FINACE_HEADLINE_COLUMN_ID = 10008
  RSS_INFORMATION_HEADLINE_COLUMN_ID = 10009
  RSS_MANAGE_COLUMN_ID = 10010
  RSS_FINACE_LIFE_COLUMN_ID = 10011
  RSS_NBD_HEADLINE_COLUMN_ID = 10012
  RSS_NBD_REPORTER_COLUMN_ID = 10013
  NBD_ORIGINAL_COLUMN_ID = 10014
  ###Shanghai Channel###
  ###edit by zhou 2013-07-09###
  SHANGHAI_COMPLEX_INFORMATION_COLUMN_ID = 10015
  SHANGHAI_COMPLEX_FASHION_COLUMN_ID = 10016
  SHANGHAI_COMPLEX_LIVE_COLUMN_ID = 10017
  SHANGHAI_COMPLEX_EDUCATION_COLUMN_ID = 10018

  ROLLING_COLUMN_ID = 20001   #滚动新闻
  PAGE_CACHE_EXPIRE_TIME = 30.minutes

  MOBILE_NEWS_COLUMN = 198
  TOUZIBAO_NEWS_COLUMN = 199
  TOUZIBAO_CASE_COLUMN = 200
  TOUZIBAO_SALON_COLUMN = 213
  TOUZIBAO_REPORT_COLUMN = 212
  GMS_ARTICLES_COLUMN = 210

  GMS_ARTICLES_COLUMNS = [GMS_ARTICLES_COLUMN]

  FORBID_COLUMNS = [TOUZIBAO_NEWS_COLUMN]
  FORBID_ARTICLE_REQUEST_OF_COLUMNS = [TOUZIBAO_NEWS_COLUMN]

  ORIGINAL_COLUMNS = [31, 81, 82]

  SHANGHAI_COMBINED_COLUMNS = {SHANGHAI_COMPLEX_INFORMATION_COLUMN_ID => [250, 252, 233],
                               SHANGHAI_COMPLEX_FASHION_COLUMN_ID => [234, 235, 236],
                               SHANGHAI_COMPLEX_LIVE_COLUMN_ID => [238, 239, 240],
                               SHANGHAI_COMPLEX_EDUCATION_COLUMN_ID => [242, 244]}

  COMBINED_COLUMNS = {
    [23, 24, 25, 26, 27, 28] => [HOME_COMBINED_COLUMN_ID, MARKET_COMBINED_COLUMN_ID], 
    [7, 8, 9] => RSS_NEWEST_COLUMN_ID, 
    [11, 12, 23, 24, 26, 27, 32, 83] => RSS_STOCK_INVEST_COLUMN_ID, 
    [34, 35, 36, 38, 39, 40, 42, 44, 45] => RSS_COMPANY_COLUMN_ID, 
    [36, 67] => RSS_FINACE_COLUMN_ID,
    [2] => RSS_DAILY_HEADLINE_COLUMN_ID,
    [3] => RSS_FINACE_HEADLINE_COLUMN_ID,
    [7, 8] => RSS_INFORMATION_HEADLINE_COLUMN_ID,
    ORIGINAL_COLUMNS => NBD_ORIGINAL_COLUMN_ID,
    SHANGHAI_COMBINED_COLUMNS[SHANGHAI_COMPLEX_INFORMATION_COLUMN_ID] => SHANGHAI_COMPLEX_INFORMATION_COLUMN_ID,
    SHANGHAI_COMBINED_COLUMNS[SHANGHAI_COMPLEX_FASHION_COLUMN_ID] => SHANGHAI_COMPLEX_FASHION_COLUMN_ID,
    SHANGHAI_COMBINED_COLUMNS[SHANGHAI_COMPLEX_LIVE_COLUMN_ID] => SHANGHAI_COMPLEX_LIVE_COLUMN_ID,
    SHANGHAI_COMBINED_COLUMNS[SHANGHAI_COMPLEX_EDUCATION_COLUMN_ID] => SHANGHAI_COMPLEX_EDUCATION_COLUMN_ID
  }


  UNIQ_COLUMN_IDS = [12, 10001, 10002, 10003, 10004, 10005, 10006, 10007, 10008, 10009]

  FEATURE_COLUMN_HASH = { 1 => 5, 6 => 9, 10 => 11, 33 => 36, 47 => 55, 56 => 57, 61 => 69, 70 => 76, 78 => 5, 145 => 147, 119 => 121, 129 => 131, 185 => 193}

  SUBDOMAIN_NAME = {"ntt" => "智库", "west" => "西部", "auto" => "汽车", "global" => "全球", "bschool" => "管理", 
                    "life" => "品味", "news" => "资讯", "finance" => "金融", "stock" => "股票", "shanghai" => "上海", "company" => "公司", Settings.default_sub_domain => "首页"}

  SPECIAL_LAYOUT_COLUMN = ["shanghai"]

  EXPIRE_IN = 24*60*60

  NTT_SUBDOMAIN = "ntt"
  WESTER_SUBDOMAIN = "western"
  
  DIS_MAIN_NAVS = [1, 6, 10, 33, 47, 56, 61, 70] # 用于页面上显示的主导航
  NTT_COLUMNS = (101..111).to_a
  WESTER_COLUMNS = (146..171).to_a

  SUBDOMAIN_CHILD_COLUMN = {NTT_SUBDOMAIN => NTT_COLUMNS, WESTER_SUBDOMAIN => WESTER_COLUMNS}

  HOME_COLUMN_ID = 1
  NEWS_COLUMN_ID = 6
  STOCK_COLUMN_ID = 10
  COMPANY_COLUMN_ID = 33
  GLOBAL_COLUMN_ID = 47
  NTT_COLUMN_ID = 56
  LIFE_COLUMN_ID = 61
  BSCHOOL_COLUMN_ID = 70
  FINANCE_COLUMN_ID = 119
  AUTO_COLUMN_ID = 129
  WEST_COLUMN_ID = 145
  SHANGHAI_COLUMN_ID = 226

  PARENT_COLUMN_IDS = [HOME_COLUMN_ID, NEWS_COLUMN_ID, STOCK_COLUMN_ID, COMPANY_COLUMN_ID, GLOBAL_COLUMN_ID, NTT_COLUMN_ID, 
                       LIFE_COLUMN_ID, BSCHOOL_COLUMN_ID, FINANCE_COLUMN_ID, AUTO_COLUMN_ID, WEST_COLUMN_ID, SHANGHAI_COLUMN_ID]

  SPECIAL_SKIN_COLUMN_IDS = [SHANGHAI_COLUMN_ID]

  # 用于页面上显示的二级导航
  DIS_SUB_NAVS = { 
    HOME_COLUMN_ID => [2, 3, 4, 5, 183],
    NEWS_COLUMN_ID => [7, 8, 9],
    STOCK_COLUMN_ID => [23, 24, 26, 27, 37, 28, 29, 30, 31, 32],
    COMPANY_COLUMN_ID => [38, 39, 40, 42, 44, 45],
    GLOBAL_COLUMN_ID => [49, 51, 53, 54, 55],
    NTT_COLUMN_ID => [102, 103, 117, 108, 60],
    LIFE_COLUMN_ID => [63, 64, 65, 66, 67],
    BSCHOOL_COLUMN_ID => [72, 73, 74, 76],
    78 => [80],
    FINANCE_COLUMN_ID => [139, 122, 123, 124, 125, 126, 127, 128],
    AUTO_COLUMN_ID => [140, 133, 134, 135, 136, 137, 138],
    197 => [198, 200], 
    SHANGHAI_COLUMN_ID => Column::SHANGHAI_COMBINED_COLUMNS.values.flatten
  } 

  DIS_SUB_NAVS_FOR_SITEMAP = DIS_SUB_NAVS.merge({WEST_COLUMN_ID => [151, 152, 153, 154, 155, 162, 163, 164]})
  
  COLUMN_MORE = {1 => 91, 6 => 92, 10 => 93, 33 => 94, 47 => 95, 61 => 97, 70 => 98, 78 => 99, 119 => 141, 129 => 142, 145 => 172}
  COLUMN_PICTURE = {1 => 4, 6 => 214, 10 => 215, 33 => 216, 47 => 217, 61 => 218, 70 => 219, 119 => 220, 129 => 221, 145 => 148, 193 => 222}

  EXCEPT_IDS = [4, 5, 8, 9, 61, 62, 63]

  #西部频道 子栏目类别
  XB_REGION_NAVS = [151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161]
  XB_INDUSTRY_NAVS = [162, 163, 164, 165, 166, 167, 168, 169]

  # 搜索屏蔽栏目, by zhou 2013-07-18
  SEARCHE_FORBID_COLUMN_IDS = [MOBILE_NEWS_COLUMN, TOUZIBAO_NEWS_COLUMN, GMS_ARTICLES_COLUMN]
  
  ACTIVE = 1
  DEPRECATED = 2
  
  acts_as_tree :order => "id asc"

  NOT_RECORD_HOT_IDS = [4, 5, Column.find(6).child_ids, Column.find(61).child_ids, Column.find(185).child_ids].flatten

  STATIC_PAGE_COLUMN_IDS = {4 => :image_news, 5 => :featured_articles, 8 => :focus_articles, 100 => :nbd_weekly_comment}
  include CacheCallback::HotResult

  has_many :staffs_permissions
  has_many :staffs, :through => :staffs_permissions
  
  has_one :columns_user, :dependent => :destroy
  has_one :user, :through => :columns_user
  has_many :articles_columns
  has_many :articles, :through => :articles_columns

  has_many :visable_children, :foreign_key => :parent_id, :class_name => 'Column', :conditions => {:console_display => 1}
  belongs_to :visable_parent, :foreign_key => :parent_id, :class_name => 'Column'
  belongs_to :charge_staff, :foreign_key => :staff_id_in_charge, :class_name => 'Staff'

  has_many :column_performance_logs

  scope :basic_columns, where(:parent_id => nil).order("id asc")
  scope :console_displayable, where(:console_display => 1)
  default_scope :conditions => {:status => ACTIVE}

  scope :displaied_columns, where(:console_display => 1)
  
  def all_articles
    if self.parent_id.nil?
      column_ids = self.child_ids
      return [] if column_ids.blank?
      article_ids = ArticlesColumn.select(:article_id).where(:column_id => column_ids).map(&:article_id)
      Article.where(:id => article_ids)
    else
      self.articles
    end
  end
  
  def name_for_select
    self.parent_id.nil? ? self.name : "&nbsp;&nbsp;#{self.name}".html_safe
  end
  
  def change_articles_pos(moved_article, target)
    target_article_id = target.is_a?(Integer) ? target : target.id
    positions = ArticlesColumn.where(:column_id => self.id, :article_id => [moved_article.id, target_article_id]).to_a.group_by(&:article_id)
    return "faild" if positions.count < 2
    moved_positions = positions[moved_article.id].first
    target_positions = positions[target_article_id].first
    Column.transaction do
      if moved_positions.pos > target_positions.pos
        ArticlesColumn.update_all("pos = pos+1", ["column_id =? and pos between ? and ?", self.id, target_positions.pos, moved_positions.pos - 1])
      else
        ArticlesColumn.update_all("pos = pos-1", ["column_id =? and pos between ? and ?", self.id, moved_positions.pos + 1, target_positions.pos])
      end
      moved_positions.pos = target_positions.pos
      moved_positions.save!
      self.updated_at = Time.now
      self.save!
      return "success"
    end
    return "faild"
  end
  
  def add_articles(articles)
    saved_ids = ArticlesColumn.where(:column_id => self.id, :article_id => articles.map(&:id)).select(:article_id).map(&:article_id)
    articles = articles.group_by(&:id)
    saved_ids.each do |s|
      articles.delete(s)
    end
    Column.transaction do
      articles.values.each do |article|
        self.max_pos = self.max_pos + 1
        ArticlesColumn.create(:column_id => self.id, :article_id => article.first.id, :pos => self.max_pos, :status => article.first.status)
      end
      self.save!
      return "success"
    end
    return "faild"
  end
  
  def is_ntt_column?
     self.id == 56 or (self.parent.present? and self.parent.id == 56)
  end
  
  def is_west_column?
    self.id == 145 or (self.parent.present? and self.parent.id == 145)
  end
  
  def special_column
    if is_ntt_column?
      "ntt"
    elsif is_west_column?
      "west"
    else
      "normal"
    end
  end

  def show_name
    "#{self.parent.name}-#{self.name}"
  end

  def charge_staff_id
    parent_id.nil? ? staff_id_in_charge : Column.where(:id => parent_id).first.staff_id_in_charge
  end

  def hot_articles(limit = 10, asso_hash = {})
    Article.hot_column_articles(id, limit, asso_hash)
  end

  class << self
    
    def aggregate_articles(column_ids, limit)
      return [] if column_ids.blank?
      
      # performance! Vincent 2011-09-23
      # ArticlesColumn.select([:article_id, :pos]).where(:column_id => column_ids, :status => Article::PUBLISHED).order("pos DESC").includes(:article => {:pages => :image}).limit(limit)
      
      article_ids = []
      column_ids.each do |column_id|
        article_ids << ArticlesColumn.select([:article_id, :pos]).where(:column_id => column_id, :status => Article::PUBLISHED).order("pos DESC").limit(10).map(&:article_id).compact
      end
      Article.where(:id => article_ids).includes(:pages).order("id DESC").limit(limit)
      
    end

    def column_id_to_subdomain(id)
      column = Column.where(:id => id).first
      column = Column.where(:id => column.parent_id).first if column.visable_parent.present?
      column_subdomain = if column.present?
        column_name = column.name
        SUBDOMAIN_NAME.invert[column_name].present? ? SUBDOMAIN_NAME.invert[column_name] : Settings.default_sub_domain
      else
        nil
      end
      return column_subdomain
    end
    
  end
  
end


# == Schema Information
#
# Table name: columns
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     not null
#  parent_id  :integer(4)
#  max_pos    :integer(4)      default(0), not null
#  created_at :datetime
#  updated_at :datetime
#
