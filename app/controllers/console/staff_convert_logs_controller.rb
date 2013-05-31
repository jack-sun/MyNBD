#encoding: utf-8
class Console::StaffConvertLogsController < Console::ConsoleBaseController

  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :is_own_convert_log?

  def new
    @staff_convert_log = StaffConvertLog.new
    @staff = Staff.find(params[:staff_id])
    @console, @news_console, @common_console = init_work_log
    @console == 'news' ? @staff_work_log = true : @common_navs = "staff_center_index"
  end

  def create
    @staff_convert_log = StaffConvertLog.new(params[:staff_convert_log])
    @staff_convert_log.staff_id = params[:staff_id]
    @staff_convert_log.staff_id_in_charge = @current_staff.id if @current_staff.authority_of_common?
    @staff = Staff.find(params[:staff_id])
    @console, @news_console, @common_console = init_work_log
    if @staff_convert_log.save
      flash[:notice] = "修改成功！"
      redirect_to console_staff_work_log_url(@staff, :console => @console, :page => session[:staff_convert_log_page])
      session.delete :staff_convert_log_page
    else
      render :new
    end
  end

  def edit
    @staff = Staff.find(params[:staff_id])
    @staff_convert_log = StaffConvertLog.find(params[:id])
    @console, @news_console, @common_console = init_work_log
  end

  def update
    @staff_convert_log = StaffConvertLog.find_by_staff_id(params[:staff_id])
    @staff = Staff.find(params[:staff_id])
    @console, @news_console, @common_console = init_work_log
    unless params[:staff_convert_log][:status] == @staff_convert_log.status
      return render :edit unless @staff_convert_log.update_attribute(:staff_id_in_charge, @current_staff.id)
    end
    if @staff_convert_log.update_attributes params[:staff_convert_log]
      flash[:notice] = "修改成功！"
      redirect_to console_staff_work_log_url(@staff, :console => @console, :page => session[:staff_convert_log_page])
      session.delete :staff_convert_log_page
    else
      render :edit
    end
  end

  private

  def is_own_convert_log?
    staff = Staff.find(params[:staff_id])
    return render :text => "唉，你的权限不够啊！" if staff.id != @current_staff.id && !(@current_staff.authority_of_common?)
  end
end
