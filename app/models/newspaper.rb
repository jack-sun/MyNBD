# encoding: utf-8
class Newspaper < ActiveRecord::Base
  include Redis::Objects
  hash_key :file_status
  
  paginates_per Settings.count_per_page
  
  scope :published, where(:status => 1)
  
  STATUS_DRAFT = 0
  STATUS_PUBLISHED = 1
  STATUS_BANNDED = 2

  STATUS_PARSE = 0
  STATUS_PARSE_ERROR = -1
  STATUS_PARSE_SUCCESS = 1

  API_EXPIRE_IN = 1.week
  
  STATUS = {STATUS_DRAFT => "解析中", STATUS_PARSE_ERROR => "解析失败", STATUS_PARSE_SUCCESS => "解析成功"}
  
  ALL_PAGES = (1..16).to_a.map(&:to_s)
  
  has_many :articles_newspapers, :dependent => :destroy
  has_many :articles, :through => :articles_newspapers
  belongs_to :staff
  
  def add_articles(articles_data)
    articles_data.each do |article_data|
      logger.debug "==============+#{article_data}"
      articles_params = attributes_of(Article,article_data).merge({'column_ids' => [79], :status => 1, :allow_comment => false, :is_rolling_news => true}) # pls make sure to fill the correct column id value, which map to '今日报纸'
      article = self.staff.create_article(articles_params)
      #article.pages.create(:content => article_data.delete('content').map{|p| "<p>#{p}</p>"}.join(""))
      p = Page.create(:content => article_data.delete('content').map{|p| "<p>#{p}</p>"}.join(""), :article_id => article.id)
      logger.info "-----------------------page: #{p.inspect}--------errors: #{p.errors}" if p.errors.present?
      self.articles_newspapers.create(attributes_of(ArticlesNewspaper, article_data).merge({ "article_id" => article.id }))
    end
  end
  
  def attributes_of(k_class, newspaper)
    newspaper.extract!(*(k_class.column_names & (newspaper.keys)))
  end

  
  def saved_pages
    self.articles_newspapers.select("distinct(page)").to_a.map(&:page)
  end

  # temp disable this feature because permission bug, Vincent, 2011-12-09
  #after_save :save_outline
  def save_outline
    f = File.new("#{Rails.root}/public/newspapers/outline/#{self.n_index}.txt", "w", File::CREAT)
    self.articles_newspapers.includes(:article).to_a.group_by{|x| x.section}.each do |section, articles|
      f.puts section
      f.puts ""
      articles.each do |article|
        a = article.article
        f.puts "#{article_url(a)}    #{a.title}"
      end
      f.puts ""
    end
    f.close
  end

  def article_url(article)
    "#{Settings.host}/articles/#{article.created_at.strftime("%Y-%m-%d")}/#{article.id}"
  end

  def name
    self.n_index
  end

  def api_newspaper_cache_key
    Article::API_NEWSPAPER_CACHE_KEY.gsub('$newspaper_id', self.id.to_s)
  end
end
