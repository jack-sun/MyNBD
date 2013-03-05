#encoding:utf-8
class Console::StaffsController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_common_console, :except => [:change_password] #, :only => [:update_target]
  
  def index
      @staff_type = params[:type].try(:to_i) || Staff::TYPE_EDITOR
      @stats_type = params[:status].try(:to_i) || Staff::STATUS_ACTIVE
      @stats = Staff.where({:status => @stats_type,:user_type => @staff_type}).page(params[:page]).per(15)

      @common_navs = "staff_center_index"
    #  @stats = @stats.where({:user_type => @staff_type})
    #  @stats = Staff.common_editors.where(:status => 1).page(params[:page]).per(15)
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
      @common_navs = "staff_center_index"
      @stat = Staff.where(:name => params[:id]).first
      @stats_type = params[:status].try(:to_i) || 1
      @order = params[:order] || "desc"
      @articles = @stat.articles.where({:status => @stats_type}).includes({:columns => :parent},:weibo,:articles_columns).order("articles.id #{@order}").page(params[:page]).per(15)
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

end
