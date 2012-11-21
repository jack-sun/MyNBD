class LivesController < ApplicationController
  
  layout "weibo"
  before_filter :authorize, :except => [:out_link]
  skip_filter :current_user, :only => [:out_link]
  
  def index
    @lives = Live.all.order("id DESC")
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lives }
    end
  end
  
  # GET /lives/1
  # GET /lives/1.xml
  def show
    @live = Live.where(:id => params[:id]).first
    @live_talks = @live.live_talks.where(["(talk_type in (0 ,2)  or answer_count > 0)", LiveTalk::TYPE_TALK]).includes([{:weibo => :owner}, {:live_answers => {:weibo => :owner} }]).page(params[:page])
    
    # @live_talks = if @live.is_over?
      # @live_talks.order("id asc") 
    # else
      # @live_talks.order("id desc")
    # end
    @live_talks = @live_talks.order("updated_at desc") if @live.is_order_by_updated_at?
    @live_talks = @live_talks.order("id desc") if @live.is_order_by_created_at? 
    
    @is_compere = @current_user && @current_user.is_important_user_of?(@live)

    if @is_compere
      @live_talk = @live.live_talks.new(:talk_type => 0)
    else
      @live_talks = @live_talks.where(:status => 1)
      @live_talk = @live.live_talks.new(:talk_type => 1)
    end
    @live_talk.question_page = "0"

    @market_express = {:articles => Article.of_column(12, 10) ,:id => 12}#行情快讯
    @relate_lives = Live.order("id DESC").limit(10)
    
    render :origin_show
    
#    case @live.l_type
#    when Live::TYPE_STOCK
#      render :origin_show
#    else
#      render :origin_show
#    end
  end

  def questions
    @live = Live.where(:id => params[:id]).first
    @is_compere = @current_user && @current_user.is_important_user_of?(@live)
    @relate_lives = Live.order("id DESC").limit(10)
    @live_talks = @live.live_talks.question.order("id desc").includes([{:weibo => :owner}, {:live_answers => {:weibo => :owner} }]).page(params[:page])
    @only_question = true
    if @is_compere
      @live_talk = @live.live_talks.new(:talk_type => 0)
    else
      @live_talks = @live_talks.where(:status => 1)
      @live_talk = @live.live_talks.new(:talk_type => 1)
    end
    @live_talk.question_page = "1"
    render :origin_show
  end
  
  def today
    @live = Live.stock_lives.last
      @live_talks = @live.live_talks.where(["(talk_type = ? or answer_count > 0)", LiveTalk::TYPE_TALK]).order("updated_at desc").includes([{:weibo => :owner}, {:live_answers => {:weibo => :owner} }]).page(params[:page])
    @is_compere = @current_user.try(:id).to_i == @live.user_id.to_i
    
    if @is_compere
      @live_talk = @live.live_talks.new(:talk_type => 0)
    else
      @live_talks = @live_talks.where(:status => 1)
      @live_talk = @live.live_talks.new(:talk_type => 1)
    end
    @live_talk.question_page = "0"
    
    @market_express = {:articles => Article.of_column(12, 10) ,:id => 12}#行情快讯
    @relate_lives = Live.order("id DESC").limit(10)
    
    render :origin_show
  end

  def check_new
    live_id = params[:id].try(:to_i)
    return render :json => {:talk => -1, :question => -1} unless live_id
    return render :json => {:talk => check_new_live_talks(live_id, params[:talk_timeline]), :question => check_new_live_question(live_id, params[:question_timeline])}
  end

  def fetch_new
    @live = Live.find(params[:id])
    @is_compere = @current_user.is_important_user_of?(@live)
    last_updated_at = Time.at(params[:timeline].to_i)
    @question_page = params[:type] == LiveTalk::TYPE_QUESTION.to_s
    if @question_page
      @live_talks = @live.live_talks.question.where(["updated_at > ?", last_updated_at]).order("id desc").includes([{:weibo => :owner}, {:live_answers => {:weibo => :owner} }])
    else
      @live_talks = @live.live_talks.where(["(updated_at > ?) and (talk_type in (0, 2) or answer_count > 0)", last_updated_at]).order("id desc").includes([{:weibo => :owner}, {:live_answers => {:weibo => :owner} }])
    end
  end

  def out_link
    @live = Live.find(params[:id])
    @is_compere = nil
    
    
    @live_talks = @live.live_talks.includes([:weibo => :owner, :live_answers => {:weibo => :owner}]).page(params[:page]).per(20)
    @live_talks = if @live.is_over?
      @live_talks.order("id asc") 
    else
      @live_talks.order("id desc")
    end
    
    render :layout => false
  end

  private 
  def check_new_live_talks(live_id, timeline)
    check_new_items(live_id, LiveTalk::TYPE_TALK, timeline)
  end

  def check_new_live_question(live_id, timeline)
    check_new_items(live_id, LiveTalk::TYPE_QUESTION, timeline)
  end

  def check_new_items(live_id, talk_type, talk_timeline)
    timeline, continue = Live.get_timeline(live_id, talk_type)
    expire = Live.check_expire(live_id)
    if !timeline.nil? && timeline.to_i > talk_timeline.to_i
      return 1
    elsif continue == "0" or expire
      return -1
    else
      return 0
    end
  end
  
end
