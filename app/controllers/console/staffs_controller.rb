#encoding:utf-8
class Console::StaffsController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_common_console, :except => [:change_password, :news_show_articles, :statistics_index, :statistics_show_articles]
  before_filter :init_news_console, :only => [:news_show_articles]
  before_filter :init_statistics_console, :only => [:statistics_index, :statistics_show_articles]

  def index
      @staff_type = params[:type].try(:to_i) || Staff::TYPE_EDITOR
      @stats_type = params[:status].try(:to_i) || Staff::STATUS_ACTIVE
      @stats = Staff.where({:status => @stats_type,:user_type => @staff_type}).page(params[:page]).per(15)
      @common_navs = "staff_center_index"
  end

  def ban_staff
      Staff.find(params[:id]).ban
      redirect_to action: "index"
  end

  def active_staff
      Staff.find(params[:id]).active
      redirect_to action: "index"
  end

  def show_articles
    @console = 'common'
    get_staff_articles
  end


  def news_show_articles
    get_staff_articles
    render :show_articles
  end

  def statistics_show_articles
    @statistics_navs = "staff_statistics"
    get_staff_articles
    render :show_articles
  end  

  def new
      @common_navs = "staff_center_new"
      @staff = Staff.new
  end

  def create
      @staff = Staff.new(params[:staff])
      @staff.add_authorities(params[:permissions])
      if @staff.save
        redirect_to action: 'index'
      else
        render action: 'new'
      end
  end

  #def destroy
    #Staff.find(params[:id]).destroy
    #redirect_to action: "index"
  #end

  def edit
    @staff = Staff.find(params[:id])
  end
  
  def update
    @staff = Staff.find(params[:id])
    if @staff.update_attributes(params[:staff])
      @staff.add_authorities(params[:permissions])
      redirect_to action: 'index'
    else
      render action: 'edit'
    end
  end

  def update_target
    @staff = Staff.where(:real_name => params[:editor_name]).first
    return render :text => "failed" if @staff.nil?
    @staff.target_per_day = params[:target]
    return render :text => @staff.save
  end
  
  def change_password
    
    if request.get?
      render(:layout=>'application')  
    else
      old_password = params[:staff].delete(:old_password)
      if old_password.blank?
        @current_staff.errors[:old_password] = "请输入正确的密码"
        render(:layout=>'application')
        return
      end
      
      new_password = params[:staff][:password]
      if new_password.blank?
        @current_staff.errors[:password] = "密码不能为空"
        render(:layout=>'application')
        return
      end
      
      if Staff.authenticate(@current_staff.name, old_password)
        if @current_staff.update_attributes(params[:staff])
          update_staff_session(@current_staff)
          return redirect_to published_console_articles_url, :notice => "密码更改成功"
        else
          render(:layout=>'application')
          return
        end
      else
        @current_staff.errors[:old_password] = "密码不匹配，请重新输入旧密码"
        render(:layout=>'application')
        return
      end
    end
  end

  def statistics_index
    @console = 'statistics'
    @statistics_navs = "staff_statistics"
    @stats = Staff.where("status = ? and (user_type = ? or user_type = ?)", Staff::STATUS_ACTIVE, Staff::TYPE_EDITOR, Staff::TYPE_EDITOR_ADMIN).page(params[:page]).per 50
  end

  private


  def get_staff_articles
    @stat = Staff.where(:name => params[:id]).first
    @stats_type = params[:status].try(:to_i) || 1
    @order = params[:order] || "desc"
    @common_navs = "staff_center_index"
    @date = params[:date]
    @staff_work_log = true
    if @date
      @find_method = @date.length < 9 ? 'month' : 'day' if @find_method.nil?
      @articles = @stat.articles.where("status = ? and articles.created_at like ?", @stats_type, "#{params[:date]}%").includes({:columns => :parent},:weibo,:articles_columns).page(params[:page]).per(15)
    else
      @articles = @stat.articles.where({:status => @stats_type}).includes({:columns => :parent},:weibo,:articles_columns).order("articles.id #{@order}").page(params[:page]).per(15)
    end
  end  
end
