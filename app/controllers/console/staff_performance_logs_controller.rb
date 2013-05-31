#encoding: utf-8
class Console::StaffPerformanceLogsController < Console::ConsoleBaseController
  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console, :only => [:news_index]
  before_filter :init_common_console, :only => [:common_index]
  before_filter :init_layout_view
  before_filter :init_statistics_console, :only => [:statistics_index]

  def statistics_index
    @statistics_navs = "staff_statistics"
    get_staff_performance_logs
    render :show
  end

  def common_index
    @console = 'common'
    @common_console = true
    @staff_work_log = true
    @common_navs = "staff_center_index"
    get_staff_performance_logs
    render :show    
  end

  def news_index
    @console, @news_console, @common_console = init_work_log
    @staff_work_log = true
    @console = 'news'
    @news_console = true
    @common_navs = "staff_center_index"
    get_staff_performance_logs
    render :show    
  end

  def edit
    # @console = params[:console]
    # @staff_performance_log = StaffPerformanceLog.find(params[:id])
    @staff = @staff_performance_log.staff
  end
  
  def update
    @console = params[:console]
    unless params[:staff_performance_log][:review_staff_id].nil?
      if @staff_performance_log.update_attributes(params[:staff_performance_log])
        flash[:notice] = "修改成功！"
        redirect_to staff_permance_index_helper_path(params[:staff_id],'day')
      else
        render action: 'edit'
      end
    else
      StaffPerformanceLog.transaction do
        @staff_performance_log.update_attributes(params[:staff_performance_log])
        @staff_performance_log.update_attributes(:convert_count_reviewed => StaffPerformanceLog::UNREVIEW)
        flash[:notice] = "修改成功！"
        return redirect_to staff_permance_index_helper_path(params[:staff_id],'day')
      end
      return render action: 'edit'
    end
  end

  private

  def staff_permance_index_helper_path(staff, find_method)
    return common_index_console_staff_staff_performance_logs_path(staff, find_method) if @console == 'common'
    return news_index_console_staff_staff_performance_logs_path(staff, find_method) if @console == 'news'
  end
  # helper_method :staff_permance_index_helper_path  

  def get_staff_performance_logs
    @staff_performance_logs = if @find_method == 'month'
      Kaminari.paginate_array(StaffPerformanceLog.get_performance_logs(params[:staff_id], 'month').reverse!).page(params[:page]).per(20)
    elsif @find_method == 'day'
      StaffPerformanceLog.get_performance_logs(params[:staff_id], 'day').page(params[:page]).per(30)
    end    
  end

  def init_layout_view
    @console = params[:console] if params.has_key?(:console)
    @staff_performance_log = StaffPerformanceLog.find(params[:id]) if params.has_key?(:id)
    @find_method = params[:find_method] if params.has_key?(:find_method)
    @staff = Staff.find(params[:staff_id]) if params.has_key?(:staff_id)
    if @console == 'common' && @current_staff.authority_of_common?
      @common_console = true
      @news_console = false
    elsif @console == 'news'
      @common_console = false
      @news_console = true
    end   
  end

end
