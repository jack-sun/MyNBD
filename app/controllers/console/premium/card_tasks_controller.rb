#encoding: utf-8
require 'nbd/mobile_newspaper_account_xls'
class Console::Premium::CardTasksController < ApplicationController

  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_mobile_newspaper_console
  before_filter :is_card_task_creater?, :only => [:new, :create, :make_card]
  before_filter :is_card_task_reviewer?, :only => [:review, :unreview]

  include Nbd::MobileNewspaperAccountXls

  def index
    @service_card_type = true
    @service_card_type = "create"
    case params[:query]
    when "unreview"
      @card_tasks = CardTask.where('status = ?', 0).order('id desc').page(params[:page]).per(20)
    when "reviewed"
      @card_tasks = CardTask.where('status = ?', 1).order('id desc').page(params[:page]).per(20)
    when "finished"
      @card_tasks = CardTask.where('status = ? and proceed = ?', 1, 1).order('id desc').page(params[:page]).per(20)
    else
      @card_tasks = CardTask.order('id desc').page(params[:page]).per(20)
    end
    @query = params[:query]
    session.delete :card_task_show_cards_page
    session[:card_task_show_cards_page] = params[:page]
    session[:card_task_redirect_to] = @query
  end

  def new
    @service_card_type = true
    @service_card_type = "create"
    @card_task = CardTask.new
  end

  def create
    flash[:notice] = "子任务不能为空"
    @card_task = CardTask.new
    render :new and return unless params[:card_task].has_key? :card_sub_tasks_attributes

    @card_task = CardTask.new(params[:card_task])
    @card_task.staff_id = @current_staff.id
    if @card_task.save
      flash[:notice] = "任务创建成功"
      redirect_to console_premium_card_tasks_url and return
    else
      flash[:notice] = "表单存在错误"
      render :new and return
    end
  end

  def show_cards
    @service_card_type = true
    @service_card_type = "create"
    @card_task = CardTask.where(:id => params[:id]).first
    @page = session[:card_task_show_cards_page]

    @stats_type = params[:type] || ServiceCard::STATUS_UNACTIVATED.to_s
    service_cards = @card_task.service_cards.select { |service_card| service_card.status.to_s == @stats_type }
    @service_cards = Kaminari.paginate_array(service_cards).page(params[:page]).per(20)
    render :template => "console/premium/service_cards/index" and return
  end

  def review
    @card_task = CardTask.where(:id => params[:id]).first
    if @card_task.update_attributes(:status => CardTask::STATUS_REVIEWED, :review_staff_id => @current_staff.id)
      flash[:notice] = "审核成功"
      if session[:card_task_redirect_to].present?
        redirect_to console_premium_card_tasks_url(:query => session[:card_task_redirect_to])
        session.delete :card_task_redirect_to and return
      else
        redirect_to console_premium_card_tasks_url and return
      end
    else
      @service_card_type = true
      @service_card_type = "create"
      @card_tasks = CardTask.scoped.page(params[:page]).per(20)
      flash[:notice] = "审核失败"
      if session[:card_task_redirect_to].present?
        render :index, :params => { :query => "unreview" }
        session.delete :card_task_redirect_to and return
      else
        render :index and return
      end
    end
  end

  def unreview
    @card_task = CardTask.where(:id => params[:id]).first
    begin
      @card_task.unreview
      flash[:notice] = "取消成功"
      if session[:card_task_redirect_to].present?
        redirect_to console_premium_card_tasks_url(:query => session[:card_task_redirect_to])
        session.delete :card_task_redirect_to and return
      else
        redirect_to console_premium_card_tasks_url and return
      end
    rescue ActiveRecord::Rollback
      @service_card_type = true
      @service_card_type = "create"
      @card_tasks = CardTask.scoped.page(params[:page]).per(20)
      flash[:notice] = "取消失败"
      if session[:card_task_redirect_to].present?
        render :index, :params => { :query => session[:card_task_redirect_to] }
        session.delete :card_task_redirect_to and return
      else
        render :index and return
      end
    end
  end

  def batch_review
    ids = params[:card_tasks_ids].split(",")
    card_tasks = []
    ids.each do |id| 
      card_task = CardTask.where(:id => id).first
      card_tasks << card_task if card_task.status == CardTask::STATUS_UNREVIEW
    end
    begin
      CardTask.transaction do
        card_tasks.each { |card_task| card_task.update_attributes!(:status => CardTask::STATUS_REVIEWED, 
                                                                   :review_staff_id => @current_staff.id) }
      end
    rescue ActiveRecord::Rollback
      flash[:notice] = "审核失败"
    else
      flash[:notice] = "审核成功"
    ensure
      @service_card_type = true
      @service_card_type = "create"
      @card_tasks = CardTask.scoped.page(params[:page]).per(20)
      render :index and return
    end
  end

  def batch_unreview
    ids = params[:card_tasks_ids].split(",")
    card_tasks = []
    ids.each do |id| 
      card_task = CardTask.where(:id => id).first
      card_tasks << card_task if card_task.status == CardTask::STATUS_REVIEWED
    end
    begin
      CardTask.transaction do
        card_tasks.each { |card_task| card_task.unreview }
      end
    rescue ActiveRecord::Rollback
      flash[:notice] = "取消失败"
    else
      flash[:notice] = "取消成功"
    ensure
      @service_card_type = true
      @service_card_type = "create"
      @card_tasks = CardTask.scoped.page(params[:page]).per(20)
      render :index and return
    end
  end

  # def make_card
  #   @card_task = CardTask.where(:id => params[:id]).first
  #   @card_task.make_card
  #   flash[:notice] = "生成卡号中…"
  #   redirect_to console_premium_card_tasks_url and return
  #   # begin
  #   #   @card_task.make_card
  #   # rescue ActiveRecord::Rollback
  #   #   @service_card_type = true
  #   #   @service_card_type = "create"
  #   #   @card_tasks = CardTask.scoped.page(params[:page]).per(20)
  #   #   flash[:notice] = "制作失败"
  #   #   render :index and return
  #   # else
  #   #   flash[:notice] = "制作成功"
  #   #   redirect_to console_premium_card_tasks_url and return
  #   # end
  # end

  # def check_process_status
  #   card_task = CardTask.where(:id => params[:id]).first
  #   card_task.process_status
  #   respond_to do |format|
  #     format.json { render json: { :proceed => card_task.process_status }.to_json }
  #   end
  # end

  def batch_check_process_status
    ids = params[:card_tasks_ids].split(",")
    process_status = []
    ids.each do |id|
      card_task = CardTask.where(:id => id).first
      process_status << { :id => card_task.id, :proceed => card_task.proceed, 
                          :status_words => status_words(card_task), :progress_percentage => card_task.progress_percentage }
      # process_status << { :id => card_task.id, :proceed => card_task.proceed, :status_words => status_words(card_task) }
    end
    respond_to do |format|
      format.json { render json: process_status.to_json }
    end
  end

  def batch_make_card
    ids = params[:card_tasks_ids].split(",")
    ids.each do |id|
      card_task = CardTask.where(:id => id).first
      card_task.make_card if card_task.status == CardTask::STATUS_REVIEWED
    end
    flash[:notice] = "生成卡号中…"
    @card_tasks = CardTask.scoped.page(params[:page]).per(20)
    render :index
  end

  def download_as_xls
    card_task = CardTask.where(:id => params[:id]).first
    file_path = generate_xls_for_card_task card_task
    send_file file_path
  end

  private

  def is_card_task_creater?
    return render :text => "唉，你的权限不够啊！" unless Settings.card_task_create_staff_names.include? @current_staff.name
  end

  def is_card_task_reviewer?
    return render :text => "唉，你的权限不够啊！" unless Settings.card_task_review_staff_names.include? @current_staff.name
  end

  def status_words card_task
    status_words = ""
    status_words << card_task.reviewed_staff.try(:real_name) unless card_task.status == CardTask::STATUS_UNREVIEW
    status_words << "#{card_task.converted_status}，"
    if card_task.proceed == CardTask::PROCEED_PROCESSING
      status_words << "正在生成卡号：#{card_task.progress_percentage}"
      # status_words << "正在生成卡号，请稍后"
    else
      status_words << "#{card_task.converted_proceed}"
    end
    return status_words
  end
  helper_method :status_words

end
