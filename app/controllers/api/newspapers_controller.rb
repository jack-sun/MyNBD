#encoding: utf-8
require 'nbd/cache_filter'
class Api::NewspapersController < ApplicationController
  include Nbd::CacheFilter

  include Api::ApiUtils

  before_filter :newspaper_n_index

  def articles
    return render_newspaper(@newspaper)
  end

  def check_status
    return render_status(@newspaper)
  end

  private

  def newspaper_n_index
    @date = if params.has_key?(:date)
      params[:date]
    elsif params[:action] == 'articles'
      Newspaper.published.order('id DESC').includes(:articles_newspapers).first.created_at.strftime('%Y-%m-%d')
    else
      Date.current.strftime('%Y-%m-%d')
    end
    @newspaper = Newspaper.find_by_n_index(@date)
  end

  def render_newspaper(newspaper)

    unless newspaper
      json = {:newspaper => {}, :msg => "抱歉，没有找到 #{@date} 的报纸", :code => 0}
      return render :text => compress_with_zip(json, true)
    end
    result = find_by_rails_cache_or_db(newspaper.api_newspaper_cache_key, :expire_in => Newspaper::API_EXPIRE_IN) do
          render_to_string(:file => "api/newspapers/content.json.rabl")
      end
    return render :text => compress_with_zip(result)
  end

  def render_status(newspaper)
    json = {:newspaper => {:date => @date, :status => @newspaper.nil? ? 0 : 1}, :msg => "", :code => 1}
    return render :text => compress_with_zip(json, true)
  end

end
