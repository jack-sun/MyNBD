# encoding: utf-8
require 'rss/maker'
require 'rss/2.0'
require 'patch/rss_xml_patch'
require 'nbd/cache_filter'
class RssController < ApplicationController
  
  
  # expire: 所有频道RSS feed 与 column更新保持一致
  include Nbd::CacheFilter
  
  # 一般频道的RSS feed
  def feed
    @column = Column.find(params[:id])
    str = find_by_rails_cache_or_db("views/#{column_rss_content_key_by_id(@column.id)}", :expire_in => Column::EXPIRE_IN) do
      @articles = Article.of_column(@column.id, 20).map(&:article)
      feed = RSS::Maker.make("2.0") do |maker| 
        maker.channel.title = "#{@column.name} | 每日经济新闻"
        maker.channel.description = "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
        maker.channel.link = column_url(@column)
        
        article_rss_items(@articles, maker)
      end
    end
    render(:text => str)
  end
  
  def channel
     @column = Column.find(params[:id])
    str = find_by_rails_cache_or_db("views/#{column_rss_digest_content_key_by_id(@column.id)}", :expire_in => Column::EXPIRE_IN) do
      @articles = Article.of_column(@column.id, 20).map(&:article)
      feed = RSS::Maker.make("2.0") do |maker| 
        maker.channel.title = "#{@column.name} | 每日经济新闻"
        maker.channel.description = "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
        maker.channel.link = column_url(@column)
        
        article_digest_rss_items(@articles, maker)
      end
    end
    render(:text => str)
  end
  
  # 最新资讯 (7,8,9)
  def newest
    feed = cache_filter(Column::RSS_NEWEST_COLUMN_ID) do
      @articles = Column.aggregate_articles([7, 8, 9], 20)
      str = RSS::Maker.make("2.0") do |maker| 
        maker.channel.title = "每日经济新闻 - 最新资讯" 
        maker.channel.description = "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
        maker.channel.link = Settings.host
        
        article_rss_items(@articles, maker)
      end
    end
    
    render(:text => feed.to_s)
  end
  
  # 证券投资 (11, 12, 23, 24, 25, 26, 27, 32, 83 )
  def stock_invest
    feed = cache_filter(Column::RSS_STOCK_INVEST_COLUMN_ID) do
      @articles = Column.aggregate_articles([11, 12, 23, 24, 25, 26, 27, 32, 83], 20)
      str = RSS::Maker.make("2.0") do |maker| 
        maker.channel.title = "每日经济新闻 - 证券投资" 
        maker.channel.description = "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
        maker.channel.link = Settings.host
        
        article_rss_items(@articles, maker)
      end
    end
    
    render(:text => feed.to_s)
  end
  
  # 公司产业 (34, 35, 36, 38, 39, 40, 42, 44, 45)
  def company
    feed = cache_filter(Column::RSS_COMPANY_COLUMN_ID) do
      @articles = Column.aggregate_articles([34, 35, 36, 38, 39, 40, 42, 44, 45], 20)
      str = RSS::Maker.make("2.0") do |maker| 
        maker.channel.title = "每日经济新闻 - 公司产业" 
        maker.channel.description = "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
        maker.channel.link = Settings.host
        
        article_rss_items(@articles, maker)
      end
    end
    
    render(:text => feed.to_s)
  end
  
  # 金融理财 (37, 67)
  def finace
    feed = cache_filter(Column::RSS_FINACE_COLUMN_ID) do
      @articles = Column.aggregate_articles([37, 67], 20)
      str = RSS::Maker.make("2.0") do |maker| 
        maker.channel.title = "每日经济新闻 - 金融理财" 
        maker.channel.description = "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
        maker.channel.link = Settings.host
        
        article_rss_items(@articles, maker)
      end
    end
    
    render(:text => feed.to_s)
  end
  
  
  # 每日头条 (2)
  def daily_headline
    feed = cache_filter(Column::RSS_DAILY_HEADLINE_COLUMN_ID) do
      @articles = Column.aggregate_articles([2], 20)
      str = RSS::Maker.make("2.0") do |maker| 
        maker.channel.title = "每日经济新闻 - 每日头条" 
        maker.channel.description = "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
        maker.channel.link = Settings.host
        
        article_rss_items(@articles, maker)
      end
    end
    
    render(:text => feed.to_s)
  end
  
  # 财经要闻 (3)
  def finace_headline
    feed = cache_filter(Column::RSS_FINACE_HEADLINE_COLUMN_ID) do
      @articles = Column.aggregate_articles([3], 20)
      str = RSS::Maker.make("2.0") do |maker| 
        maker.channel.title = "每日经济新闻 - 财经要闻" 
        maker.channel.description = "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
        maker.channel.link = Settings.host
        
        article_rss_items(@articles, maker)
      end
    end
    
    render(:text => feed.to_s)
  end
  
  # 资讯要闻 (7, 8, 9)
  def infomation_headline
    feed = cache_filter(Column::RSS_INFORMATION_HEADLINE_COLUMN_ID) do
      @articles = Column.aggregate_articles([7, 8, 9], 20)
      str = RSS::Maker.make("2.0") do |maker| 
        maker.channel.title = "每日经济新闻 - 资讯要闻" 
        maker.channel.description = "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
        maker.channel.link = Settings.host
        
        article_rss_items(@articles, maker)
      end
    end
    
    render(:text => feed.to_s)
  end
  
  # 管理人物(71, 72, 73, 74, 75, 76)
  def manage
     feed = cache_filter(Column::RSS_MANAGE_COLUMN_ID) do
      @articles = Column.aggregate_articles([71, 72, 73, 74, 75, 76], 20)
      str = RSS::Maker.make("2.0") do |maker| 
        maker.channel.title = "每日经济新闻 - 管理人物" 
        maker.channel.description = "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
        maker.channel.link = Settings.host
        
        article_rss_items(@articles, maker)
      end
    end
    
    render(:text => feed.to_s)
  end
  
  # 财富生活 (62, 63, 64, 65, 66, 67, 68, 69)
  def finace_life
     feed = cache_filter(Column::RSS_FINACE_LIFE_COLUMN_ID) do
      @articles = Column.aggregate_articles([62, 63, 64, 65, 66, 67, 68, 69], 20)
      str = RSS::Maker.make("2.0") do |maker| 
        maker.channel.title = "每日经济新闻 - 财富生活" 
        maker.channel.description = "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
        maker.channel.link = Settings.host
        
        article_rss_items(@articles, maker)
      end
    end
    
    render(:text => feed.to_s)
  end
  
  private
  
  def article_rss_items(articles, rss_maker)
    articles.each do|a|
      item = rss_maker.items.new_item 
      item.title = a.title
      item.link = article_url(a)
      item.description = HTML::CDATA.new(nil, 0, 0, a.pages.map{|page| "<p>" + page.content + "</p>"}.join("")).to_s
      #item.enclosure = RSS::Maker::RSS20::Items::Item::Enclosure.new(article_url(a), "10", 'image/jpeg')  
      item.pubDate = a.created_at.to_s
    end
  end
  
  def article_digest_rss_items(articles, rss_maker)
    articles.each do|a|
      item = rss_maker.items.new_item 
      item.title = a.title
      item.link = article_url(a)
      item.description = HTML::CDATA.new(nil, 0, 0, a.show_digest + " <a href='#{article_url(a)}'>查看详情</a>").to_s
      item.pubDate = a.created_at.to_s
    end
  end

  def cache_filter(column_id)
    key = "views/#{column_show_content_key_by_id(column_id)}"
    str = Rails.cache.read(key)
    Rails.logger.info "-------------- get cache, key: #{key} -------------"
    return str if str
    str = yield
    Rails.cache.write(key, str)
    Rails.logger.info "-------------- write cache, key: #{key} -------------"
    return str
  end

end
