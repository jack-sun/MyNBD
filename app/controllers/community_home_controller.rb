class CommunityHomeController < ApplicationController

  layout 'site'
  before_filter :current_user
  
  def index
    @community_home_nav = true
    
    @newest_weibos = Weibo.newest_weibos(30, User::SYSTEM_USER_IDS).includes(:owner => :image)
    
    @active_users = User.active_users(24, :image)[0..11]
    
    @hot_topics = Topic.hot_topics(10)
    
    @hot_rt_weibos = Weibo.hot_rt_weibos(20, {:owner => :image})[0..7]
    
    @hot_comment_articles = Article.hot_comment_articles(20)[0..5] #temp solution, Vincent 2011-12-05

    @showed_live = Live.showed_lives(Rails.cache.read(Live::LIVE_SHOW_TYPE_KEY)||"1").order("id desc").first

    @showed_live_talks = @showed_live.live_talks.comment.published.includes([:weibo => :owner, :live_answers => {:weibo => :owner}]).order("id desc").limit(4)

    @stock = Live.stock_lives.order("id desc").first

    @qa_live_talks = @stock.live_talks.published.question.includes([:weibo => {:owner => :image}, :live_answers => {:weibo => {:owner => :image}}]).order("id desc").limit(2)
  end
  
end
