require 'nbd/cache_filter'
class Api::LivesController < ApplicationController

  skip_before_filter :authenticate
  
  include Api::ApiUtils

  include Nbd::CacheFilter

  EXPIRE_IN = 100
  INDEX_EXPIER_IN = 60

  def show
    @live = Live.published.where(:l_type => @merged_params[:l_type]).find(params[:id])
    str = find_by_rails_cache_or_db("views/#{stock_live_content_key_by_id(@live.id, true, request.url.chomp("/"))}", :expire_in => EXPIRE_IN) do
            @live_talks = stock_lives_filter(@live)
            @live_talks = reverse(@live_talks.to_a)
            render_to_string(:file => "/api/lives/show.json.rabl")
          end
    return render :text => str
  end

  def today
    @live = Live.published.where(:l_type => @merged_params[:l_type]).order("id desc").first
    str = find_by_rails_cache_or_db("views/#{stock_live_content_key_by_id(@live.id, true, request.url.chomp("/"))}", :expire_in => EXPIRE_IN) do
            @live_talks = stock_lives_filter(@live)
            @live_talks = reverse(@live_talks.to_a)
            render_to_string(:file => "/api/lives/show.json.rabl")
          end
    return render :text => str
  end

  def index
    str = find_by_rails_cache_or_db("views/#{stock_live_content_key_by_id('stock_live_index', true, request.url.chomp("/"))}", :expire_in => EXPIRE_IN) do
      @lives = Live.where(:l_type => params[:l_type]).published.includes(:user => :image)
      @lives = stock_live_index_filter(@lives)
      #@lives = Live.where(:l_type => params[:l_type]).published.includes(:user => :image)
      render_to_string(:file => "/api/lives/index.json.rabl")
    end
    return render :text => str
  end

  def check_new
    live_id = params[:id].try(:to_i)
    return render :text => "-1" if live_id.nil?
    timeline, continue = Live.get_timeline(live_id)
    expire = Live.check_expire(live_id)
    if !timeline.nil? && timeline.to_i > params[:timeline].to_i / 1000
      render :json => {:status =>1, :msg => "", :code => 0}.to_json
    elsif continue == "0" or expire
      render :json => {:status =>-1, :msg => "", :code => 0}.to_json
    else
      render :json => {:status =>0, :msg => "", :code => 0}.to_json
    end
  end

  def fetch_new
    @live = Live.find(params[:id])
    @is_compere = @current_user.is_important_user_of?(@live)
    last_updated_at = Time.at(params[:timeline].to_i)
    @live_talks = @live.live_talks.where(["updated_at > ?", last_updated_at]).includes([{:weibo => :owner}, {:live_answers => {:weibo => :owner} }])
  end
end
