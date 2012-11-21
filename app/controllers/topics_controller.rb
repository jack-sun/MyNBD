# encoding: utf-8
class TopicsController < ApplicationController
  
  layout "weibo"
  
  before_filter :authorize
  
  def index
  end

  def show
    @topic = Topic.where(:slug => params[:id]).includes(:elements).first
    raise ActiveRecord::RecordNotFound if @topic.blank? or (not @topic.is_published?)
    @topic.increment!(:click_count)
    
    cweibo_element = @topic.elements.select{|e| e.type == ElementCweibo.name.to_s}.first
    json = JSON.parse(cweibo_element.content)["body"] # if cweibo_element.present?    
    
    @tag, @keywords = json["tag"], json["keywords"]
    @weibos = Weibo.search(@keywords, :page => params[:page], :per_page => 10, :order => :id, :sort_mode => :desc, :with => {:status => 1})
  end

end
