module Console
class StockLivesController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_community_console
  # GET /stock_lives
  # GET /stock_lives.xml
  def index
    @stock_lives = StockLive.order("id DESC").page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stock_lives }
    end
  end

  # GET /stock_lives/new
  # GET /stock_lives/new.xml
  def new
    @stock_live = StockLive.new
    @stock_live.s_index = Date.today.to_s(:db)
    @stock_live.title = "#{StockLive::DEFAULT_NAME_PREFIX}#{@stock_live.s_index}"
    @stock_live.start_at = Time.now.change(:hour=>8, :min => 0)
    @stock_live.end_at = Time.now.change(:hour => 15, :min => 30)
    @compere = User.where(:id => User::SYS_USERS[:live_user_id]).first
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stock_live }
    end
  end

  # GET /stock_lives/1/edit
  def edit
    @stock_live = StockLive.where(:s_index => params[:id]).first
    @compere = User.where(:id => User::SYS_USERS[:live_user_id]).first
  end

  # POST /stock_lives
  def create
    @stock_live = StockLive.new(params[:stock_live])

    respond_to do |format|
      if @stock_live.save
        format.html { redirect_to(console_stock_lives_url, :notice => 'Stock live was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /stock_lives/1
  # PUT /stock_lives/1.xml
  def update
    @stock_live = StockLive.where(:s_index => params[:id]).first

    respond_to do |format|
      if @stock_live.update_attributes(params[:stock_live])
        format.html { redirect_to(@stock_live, :notice => 'Stock live was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stock_live.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_lives/1
  # DELETE /stock_lives/1.xml
  def destroy
    @stock_live = StockLive.where(:s_index => params[:id]).first
    @stock_live.destroy

    respond_to do |format|
      format.html { redirect_to(console_stock_lives_url) }
      format.xml  { head :ok }
    end
  end
end
end
