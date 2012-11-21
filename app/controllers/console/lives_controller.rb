#encoding:utf-8
module Console
  class LivesController < ApplicationController
    layout "console"
    skip_before_filter :current_user
    before_filter :current_staff
    before_filter :authorize_staff
    before_filter :init_community_console

    LIVE_TYPE = {Live::TYPE_STOCK => "stock", Live::TYPE_ORIGIN => "origin"}

    # GET /lives
    # GET /lives.xml
    def index
      @lives = Live.order("id DESC").includes(:user).page(params[:page])
    end

    def stock
      @lives = Live.stock_lives.order("id DESC").includes(:user).page(params[:page])
      @topics_navs = "stock_lives"
    end

    def origin
      @lives = Live.origin_lives.order("id DESC").includes(:user).page(params[:page])
      @topics_navs = "origin_lives"
    end

    def add_guest
      @guest = User.where(:nickname => params[:guest_name]).first
    end

    # GET /lives/new
    # GET /lives/new.xml
    def new
      live_type = params[:type].try(:to_i)
      return redirect_to :back, :notice => "错误" unless live_type
      if live_type == Live::TYPE_STOCK
        @live = Live.new(:l_type => Live::TYPE_STOCK)
        @live.s_index = Date.today.to_s(:db)
        @live.title = "#{Live::DEFAULT_NAME_PREFIX}#{@live.s_index}"
        @live.start_at = Time.now.change(:hour=>8, :min => 30)
        @live.end_at = Time.now.change(:hour => 15, :min => 30)
        @compere = User.where(:id => User::SYS_USERS[:live_user_id]).first
      elsif live_type == Live::TYPE_ORIGIN
        @live = Live.new(:l_type => Live::TYPE_ORIGIN)
      end
      render_by_type(@live)
    end

    # GET /lives/1/edit
    def edit
      @live = Live.where(:id => params[:id]).first
      case @live.l_type
      when Live::TYPE_STOCK
        @compere = User.where(:id => User::SYS_USERS[:live_user_id]).first
      else
      end
      render_by_type(@live)
    end

    # POST /lives
    def create
      @live = Live.new(params[:live])
      @live.status = Live::PUBLISHED
      if @live.save
        redirect_to_by_type(@live)
      else
        render_by_type(@live)
      end
    end

    # PUT /lives/1
    # PUT /lives/1.xml
    def update
      @live = Live.where(:id => params[:id]).first
      if @live.update_attributes(params[:live])
        redirect_to_by_type(@live)
      else
        render_by_type(@live)
      end
    end

    # DELETE /lives/1
    # DELETE /lives/1.xml
    def destroy
      @live = Live.where(:id => params[:id]).first
      @live.destroy
      redirect_to_by_type(@live)
    end

    def change_live_show_type
      Live.change_live_show_type(params[:type])
      render :js => "alert('操作成功');"
      expire_fragment(Live::COMMUNITY_INDEX_FRAGMENT_KEY)
    end

    private
    def init_stock_lives_navs
      @topics_navs = "stock_lives"
    end

    def init_origin_lives_navs
      @topics_navs = "origin_lives"
    end

    def init_lives_navs
      @topics_navs = @live.is_stock_lives? ? "stock_lives" : "origin_lives"
    end

    def render_or_redirect_to_by_type(live)
      if live.is_a? Live
        render_by_type(live)
      else
        redirect_to_by_type(live)
      end
    end

    def render_by_type(live)
      init_lives_navs
      return render "#{LIVE_TYPE[live.l_type]}_live_show"
    end

    def redirect_to_by_type(live)
      if live.is_a? String
        redirect_url = send("#{live}_console_lives_url")
      elsif live.respond_to?(:count)
        redirect_url = send("#{LIVE_TYPE[live.first.l_type]}_console_lives_url")
      elsif live.is_a? Live
        redirect_url = send("#{LIVE_TYPE[live.l_type]}_console_lives_url")
      end
      init_lives_navs
      return redirect_to redirect_url
    end

  end
end
