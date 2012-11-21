#encoding: utf-8
require 'nokogiri'
require 'nbd/utils'
class Article < ActiveRecord::Base

  include Redis::Objects
  set :page_cache_file_names
  value :last_important_article_id, :global => true

  ROLLING_NEWS_FRAGMENT_CACHE_KEY = "rollowing_news_cache_fragment_keys"
  HOT_ARTICLE_FRAGMENT_CACHE_KEY = "hot_article_cache_fragment_key"
  HOT_COMMENT_ARTICLE_FRAGMENT_CACHE_KEY = "hot_comment_article_cache_fragment_key"
  IMAGE_NEWS_IN_HOME_PAGE_CACHE_KEY = "column_4_path_home_index_image_news"
  IMPORTANT_ARTICLE_CACHE_KEY = "views/articles/important_article_cache"

  COPYRIGHT_FRAGMENT_CACHE_KEY = "copyright_fragment_cache_key"

  STATS_NAME = {"newspaper" => "今日报纸", "staff" => "编辑", "channel" => "频道", "column" => "栏目"}

  STATIC_CACHE_DEADLINE = 1.months.ago

  include CacheCallback::HotResult
  include ActionView::Helpers

  attr_accessor :c_id

  paginates_per Settings.count_per_page
  DRAFT = 0
  PUBLISHED = 1
  BANNDED = 2
  STATUS = {PUBLISHED => "已发布", DRAFT => "草稿", BANNDED => "屏蔽"}
  WEIBO_PREFIX = "核心提示"
  EXPIRE_IN = 60*60*24*1 #change article cache expire time to 1 days. 2011-12-21
  HOT_ARTICLE_KEY = "hot_article_and_hot_comment_article"
  
  COPYRIGHT_NO = 0
  COPYRIGHT_YES = 1

  SPECIAL_NONE = 0 #不强调
  SPECIAL_HEAVY = 1 #重磅
  SPECIAL_EXCLUSIVE = 2 #独家
  SPECIAL_FEATURE = 3 #特稿
  SPECIAL_BREAKING = 4 #突发
  SPECIAL_TRACK = 5 #追踪
  SPECIAL_EXPRESS = 6 #快讯

  ARTICLE_STATUS_MAP = {'banned' => BANNDED,'published' => PUBLISHED,'draft' => DRAFT}

  SPECIAL_OPTIONS = [["无", SPECIAL_NONE], ["重磅", SPECIAL_HEAVY], ["独家", SPECIAL_EXCLUSIVE], ["特稿", SPECIAL_FEATURE], ["突发", SPECIAL_BREAKING], ["追踪", SPECIAL_TRACK], ["快讯", SPECIAL_EXPRESS]]
  SPECIAL = {SPECIAL_NONE => "", SPECIAL_HEAVY => "重磅", SPECIAL_EXCLUSIVE => "独家", SPECIAL_FEATURE => "特稿", SPECIAL_BREAKING => "突发", SPECIAL_TRACK => "追踪", SPECIAL_EXPRESS => "快讯"}
  
  attr_accessor :publish_weibo_with_official_account
  attr_accessor :pos
  attr_accessor :section

  has_one  :articles_newspaper, :dependent => :destroy
  has_one  :newspaper, :through => :articles_newspaper

  has_many :articles_staffs, :dependent => :destroy
  has_many :staffs, :through => :articles_staffs

  has_many :articles_columnists, :dependent => :destroy
  has_many :columnists, :through => :articles_columnists

  belongs_to :weibo, :dependent => :destroy

  has_many :comments, :conditions => {:status => Comment::PUBLISHED}

  has_many :pages, :dependent => :destroy

  has_many :polls, :as => :owner, :dependent => :destroy

  has_one :article_touzibao, :dependent => :destroy

  has_many :relate_article_children, :class_name => "ArticlesChildren", :dependent => :destroy
  has_many :children_articles, :through => :relate_article_children, :source => :children

  has_many :relate_article_parent, :class_name => "ArticlesChildren", :foreign_key => "children_id", :dependent => :destroy
  has_many :parent_articles, :through => :relate_article_parent, :source => :article

  has_many :articles_columns, :dependent => :destroy
  has_many :columns, :through => :articles_columns

  has_many :article_logs

  belongs_to :image

  accepts_nested_attributes_for :pages, :allow_destroy => true#, :reject_if => lambda { |a| a[:content].blank? && a[:image_attributes].blank? }
  accepts_nested_attributes_for :image, :allow_destroy => true, :reject_if => :all_blank

  scope :published, where(:status => PUBLISHED)
  scope :draft, where(:status => DRAFT)
  scope :banned, where(:status => BANNDED)
  scope :rolling, where(:is_rolling_news => 1)
  scope :visible_comments, lambda{|user_id| where(["status = ? OR user_id = ?", PUBLISHED, user_id])}
  scope :import_articles, where(:need_push => 1)

  define_index do
    # fields
    indexes title, :sortable => true
    indexes list_title
    indexes sub_title
    indexes digest
    indexes tags
    indexes pages.content, :as => :content

    # attributes
    has :id, status, created_at, updated_at
    
    # 声明使用实时索引    
    set_property :delta => true
  end

  def is_special?
    self.special != SPECIAL_NONE
  end
  
  def is_breaking?
    self.special == SPECIAL_BREAKING
  end
  
  def is_track?
    self.special == SPECIAL_TRACK
  end
  
  def is_notice?
    self.columns.order('id asc').map(&:id).include?(118)
  end
  
  def related_articles(limit)
    column = self.columns.order("id asc").try(:to_a).try(:first)
    if column
      {:articles => ArticlesColumn.where(:column_id => column.id, :status => PUBLISHED).where(["article_id <> ?", self.id]).select([:article_id, :pos]).order("pos desc").limit(limit).includes(:article => [{:pages => :image}, :children_articles]), :id => column.id}
    else
      {}
    end
  end
  
  def recommend_articles(limit)
    if self.tags.present?
      {:articles => Article.search(self.tags.split(",").first, :page => 1, :per_page => limit, :order => :id, :sort_mode => :desc, :with => {:status => PUBLISHED}, :without => {:id => self.id}), :id => self.id}
    else #如果没有填写文章关键词，就用‘热门文章’ 内容代替
      {:articles => Article.hot_articles(5), :id => self.id}
    end
  end

  def relate_hot_articles
    first_column = self.columns.order("id asc").try(:to_a).try(:first)
    if first_column
      {:articles => Article.of_column(Column::FEATURE_COLUMN_HASH[first_column.parent_id], 4), :id => Column::FEATURE_COLUMN_HASH[first_column.parent_id]}
    else
      {}
    end
  end

  before_create :init_slug
  def init_slug
    #self.slug = Time.now.to_i
    self.slug = NBD::Utils.to_md5(id.to_s + title + Time.now.to_f.to_s)
  end

  after_create :update_important_article_id
  def update_important_article_id
    if self.need_push == 1
      Article.last_important_article_id = self.id
      Rails.cache.delete(IMPORTANT_ARTICLE_CACHE_KEY)
    end
  end
  
  after_commit :sweep_cache
  def sweep_cache
    Article.transaction do
      column_ids = ArticlesColumn.where(:article_id => self.id).map(&:column_id)
      Column.update(column_ids, Array.new(column_ids.count){ {:updated_at => Time.now} })
    end
  end
  
  after_destroy :destroy_cache_weibo_key
  def destroy_cache_weibo_key
    Weibo.weibo_article_id.delete(self.weibo_id)
  end

  def around_save
    changed = self.is_rolling_news_changed?
    yield
    t = Time.now
    if changed
        expire_cache_object("column", "rolling_news")
    end
  end

  def show_digest
   if read_attribute(:digest).blank?
      begin
        doc = Nokogiri::HTML(self.pages.first.content).search('//text()').text
        return truncate(doc, :length => 120).sub(/[\u3000\s]+/, '')
      rescue
         self.title
      end
    else
      read_attribute(:digest).sub(/[\u3000|\s]+/, '')
    end
  end
  
  def list_title
  	if read_attribute(:list_title).blank?
  		self.title
  	else
  		read_attribute(:list_title)
  	end
  end
  
  def show_ori_source
    ori_source.present? ? ori_source : "每经网综合"
  end
  
  def update_self(params, send_weibo = true)
    column_ids = params.delete(:column_ids)
    new_column_ids = column_ids ? column_ids.map(&:to_i) : []
    deprecated_column_ids = self.column_ids - new_column_ids
    added_column_ids = new_column_ids - self.column_ids

    columnist_ids = params[:columnist_ids]
    new_columnist_ids = columnist_ids ? columnist_ids.map(&:to_i) : []
    deprecated_columnist_ids = self.columnist_ids - new_columnist_ids

    if params[:image_attributes]
      image_action = params[:image_attributes].delete("action").try(:to_i)
    end
    if image_action == Image::ACTION_UPDATE
      params[:image_id] = nil
      params[:image_attributes]["id"] = nil
    elsif image_action == Image::ACTION_DESTROY
      params[:image_id] = nil
    end
    
    Article.transaction do

      unless deprecated_column_ids.blank?
        ArticlesColumn.delete_all({:article_id => self.id, :column_id => deprecated_column_ids})
        Column.where(:id => deprecated_column_ids).each do |c|
          c.updated_at = Time.now
          c.save!
        end 
      end
      
      if send_weibo
        if !added_column_ids.blank?
          self.add_columns(added_column_ids, params[:status] || 0) 
        elsif params[:allow_comment] == "1" and self.weibo_id == 0
          weibo_content = "【#{self.title}】#{self.show_digest} #{article_url(self)}" #<a href='http://#{article_url(self)}'>查看详情</a>
          first_column = self.columns.first
          ori_weibo = first_column.parent.user.create_plain_text_weibo(weibo_content) if first_column
          params["weibo_id"] = ori_weibo.id
        end
      end
      
      params["updated_at"] = Time.now

      params[:tags] = NBD::Utils.parse_tags(params[:tags]).join(", ") if params[:tags].present?
      self.delta = true
      self.update_attributes(params)
      
      # add status to articles_columns table. 2011-09-23. By Vincent
      change_columns_status(params[:status]) if is_status_changed?(params[:status])

      #update the columnists of this article
      Columnist.where(:id => deprecated_columnist_ids).each do |c|
        c.update_last_article
      end
    end
    
    return self
  end
  
  def is_allow_comment?
    self.allow_comment == 1 ? true : false
  end
  
  def is_published?
    self.status == PUBLISHED
  end
  
  def copyright?
    self.copyright == COPYRIGHT_YES
  end


  def self.create_article(params, send_weibo = true)
    column_ids = params.delete("column_ids")
    params[:tags] = NBD::Utils.parse_tags(params[:tags]).join(", ") if params[:tags].present?
    
    article = self.new(params)
    self.transaction do
      unless article.save
        return article
      end
      article.add_columns(column_ids, params["status"] || 0, send_weibo)
    end
    return article
  end

  def add_columns(column_ids, status, send_weibo = true) 
    return if column_ids.blank?
    
    Column.update_all("max_pos = max_pos + 1", {:id => column_ids})
    columns = Column.where(:id => column_ids).select([:id, :max_pos, :parent_id]).each do |c|
      ArticlesColumn.create(:pos => c.max_pos, :article_id => self.id, :column_id => c.id, :status => status)
    end
    columns = columns.map(&:root).uniq
    if send_weibo
      if self.weibo.nil?
        first_column = columns.shift
        #return if first_column.blank?
        weibo_content = "【#{self.title}】#{self.show_digest} #{article_url(self)}"
        ori_weibo = first_column.user.create_plain_text_weibo(weibo_content)
        self.weibo_id = ori_weibo.id
        Weibo.weibo_article_id[ori_weibo.id] = self.id
        self.save
        columns.each do |c|
          c.user.rt_weibo(ori_weibo, :content => Weibo::DEFAULT_RT_CONENT)
        end
      else
        columns.each do |c|  
          c.user.rt_weibo(self.weibo, :content => Weibo::DEFAULT_RT_CONENT)
        end
      end
    end
  end

  def banned?
    self.status == BANNDED
  end

  def published?
    self.status == PUBLISHED
  end

  def draft?
    self.status == DRAFT
  end
  
  def is_status_changed?(status)
    self.status == status.to_i
  end
  
  def change_columns_status(new_status)
    ArticlesColumn.update_all(["status = ?", new_status], ["article_id = ?", self.id])
  end

  def add_child_article(article)
      Article.transaction do
        self.increment!(:max_child_pos)
        if article.is_a? Article
          return ArticlesChildren.create(:article_id => self.id, :children_id => article.id, :pos => self.max_child_pos , :children_title => article.list_title, :children_url => article_url(article))
        elsif article.is_a? Hash
          return ArticlesChildren.create(article.merge!({:article_id => self.id, :pos => self.max_child_pos}))
        end
      end
      return "faild"
  end
  
  def remove_child_article(article)
    Article.transaction do
      self.relate_article_children.delete(article)

      # save article to fire after_save callback
      self.updated_at = Time.now
      self.save!
    end
  end


  def change_children_articles_pos(moved_positions, target_positions)
    Article.transaction do
      if moved_positions.pos > target_positions.pos
        ArticlesChildren.update_all("pos = pos+1", ["article_id =? and pos between ? and ?", self.id, target_positions.pos, moved_positions.pos - 1])
      else
        ArticlesChildren.update_all("pos = pos-1", ["article_id =? and pos between ? and ?", self.id, moved_positions.pos + 1, target_positions.pos])
      end
      moved_positions.pos = target_positions.pos
      moved_positions.save!
      
      # save article to fire after_save callback
      self.updated_at = Time.now
      self.save!
      
      return "success"
    end
    return "faild"
  end

  def relate_article_column_id
    c_id = self.articles_columns.last.column_id
    n = nil
    Column::DIS_SUB_NAVS.each do |k, v|
      n = k if v.include?(c_id)
    end
    n.nil? ? 80 : Column::COLUMN_MORE[n]
  end

  before_save :change_status_of_article_columns
  def change_status_of_article_columns
    if self.status_changed?
      ArticlesColumn.update_all({:status => self.status}, {:article_id => self.id})
    end
  end

  def from_ntt?
    ! ArticlesColumnist.where(:article_id => self.id).blank?
  end

  def head_article?
    self.articles_columns.map(&:column_id).include?(2)
  end

  def record_hot_article?
    Article.record_hot_article?(self.id)
  end

  def section
    self.article_touzibao.try(:section)
  end


  class << self

    def hot_articles(limit = 10, asso_hash = {})
      hot_objects("hot_cache:result:hot_article", limit, asso_hash)
    end

    def hot_comment_articles(limit = 10, asso_hash = {})
      hot_objects("hot_cache:result:hot_comment_article", limit, asso_hash)
    end
    
    def of_column(column_id, limit, include_hash = {:article => [{:pages => :image}, {:relate_article_children => :children}]})
      ArticlesColumn.where(:column_id => column_id, :status => PUBLISHED).select([:article_id, :pos]).order("articles_columns.pos desc").limit(limit).includes(include_hash)
    end

    def of_column_for_ntt(column_id, limit)
      ArticlesColumn.where(:column_id => column_id, :status => PUBLISHED).select([:article_id, :pos]).order("articles_columns.pos desc").limit(limit).includes(:article => {:columnists => :image})
    end

    
    def of_child_column(column_id)
      ArticlesColumn.where(:column_id => column_id, :status => PUBLISHED).select([:article_id, :pos]).order("articles_columns.pos desc").includes(:article => [{:pages => :image}, {:relate_article_children => :children} ])
    end

    def of_child_column_for_ntt(column_id)
      ArticlesColumn.where(:column_id => column_id, :status => PUBLISHED).select([:article_id, :pos]).order("articles_columns.pos desc").includes(:article => {:columnists => :image})
    end

    def record_hot_article?(article_id)
      (ArticlesColumn.where(:article_id => article_id, :status => PUBLISHED).select([:column_id]).map(&:column_id) & Column::NOT_RECORD_HOT_IDS).blank?
    end

  end

  private
  def article_url(article, html_suffix = true)
    if article.redirect_to.present?
      article.redirect_to
    else
      url = "#{Settings.host}/articles/#{article.created_at.strftime("%Y-%m-%d")}/#{article.id}"
      url += ".html" if html_suffix
      url
    end
  end

end


# == Schema Information
#
# Table name: articles
#
#  id                :integer(4)      not null, primary key
#  title             :string(255)     not null
#  list_title        :string(255)
#  sub_title         :string(255)
#  digest            :string(300)
#  type              :string(40)      not null
#  slug              :string(32)      not null
#  redirect_to       :string(255)
#  ori_author        :string(64)
#  ori_source        :string(64)
#  comment           :string(300)
#  click_count       :integer(4)      default(0)
#  max_child_pos     :integer(4)      default(0), not null
#  allow_comment     :integer(4)      default(1)
#  status            :integer(4)      default(0)
#  is_rollowing_news :integer(4)      default(0)
#  created_at        :datetime
#  updated_at        :datetime
#
