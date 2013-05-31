#encoding: utf-8
class Console::ColumnPerformanceLogsController < Console::ConsoleBaseController

  layout 'console'
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_news_console, :only => [:news_list, :news_index, :news_show_articles]
  before_filter :init_common_console, :only=> [:common_list, :common_index, :common_show_articles]
  before_filter :active_news_left_nav, :only => [:news_list, :news_index, :news_show_articles]
  before_filter :active_common_left_nav, :only => [:common_list, :common_index, :common_show_articles]
  before_filter :can_view_column_work_log?, :only => [:news_index, :news_show_articles]
  before_filter :redirect_to_parent_column_performance_log, :only => [:common_index, :news_index]
  before_filter :init_statistics_console, :only => [:statistics_list, :statistics_index, :statistics_show_articles]

  def news_list
    @columns = Column.basic_columns
  end

  def common_list
    @columns = Column.basic_columns
  end

  def statistics_list
    @statistics_navs = "column_statistics"
    @columns = Column.basic_columns
  end  

  def news_index
    session.delete :column_performance_log_page
    @find_method, @column, @column_performance_logs = log_list
    session[:column_performance_log_page] = params[:page]
  end

  def common_index
    session.delete :column_performance_log_page
    @find_method, @column, @column_performance_logs = log_list
    session[:column_performance_log_page] = params[:page]
  end

  def statistics_index
    @statistics_navs = "column_statistics"
    session.delete :column_performance_log_page
    @find_method, @column, @column_performance_logs = log_list
    session[:column_performance_log_page] = params[:page]
  end  

  def news_show_articles
    @column, @sub_columns, @current_column, @articles_columns, @date, @sortable = show_articles
    @column_performance_log_page = session[:column_performance_log_page]
    return render :template => "console/columns/show"
  end

  def common_show_articles
    @column, @sub_columns, @current_column, @articles_columns, @date, @sortable = show_articles
    @column_performance_log_page = session[:column_performance_log_page]
    return render :template => "console/columns/show"
  end

  def statistics_show_articles
    @statistics_navs = "column_statistics"
    @column, @sub_columns, @current_column, @articles_columns, @date, @sortable = show_articles
    @column_performance_log_page = session[:column_performance_log_page]
    return render :template => "console/columns/show"
  end  

  private

  def active_news_left_nav
    @column_work_log = true
  end

  def active_common_left_nav
    @column_work_log = true
  end

  def show_articles
    column = Column.find(params[:column_id])
    if column.parent_id.nil?
      @column = column
      @sub_columns = @column.children.console_displayable
      @current_column = @sub_columns.first
    else
      @column = Column.find(column.parent_id)
      @sub_columns = @column.children.console_displayable
      @current_column = column
    end
    @articles_columns = @current_column.articles_columns.where("articles_columns.created_at like ?","#{params[:date]}%").order("pos desc").includes({:article => [{:columns => :parent}, :staffs, :pages, :children_articles, :weibo]}).page params[:page]
    @date = params[:date]
    @sortable = true
    return @column, @sub_columns, @current_column, @articles_columns, @date, @sortable
  end

  def log_list
    find_method = params[:find_method].nil? ? 'day' : params[:find_method]
    column = Column.find(params[:column_id])
    column_performance_logs = if params[:find_method] == 'day' || params[:find_method].nil?
      ColumnPerformanceLog.where(:column_id => params[:column_id]).order("date_at desc").page(params[:page]).per(20)
    elsif params[:find_method] == 'month'
      Kaminari.paginate_array(ColumnPerformanceLog.find_by_month(column).reverse!).page(params[:page]).per(20)
    end
    return find_method, column, column_performance_logs
  end

  def can_view_column_work_log?
    return render :text => "唉，你的权限不够啊！" if @current_staff.id != Column.find(params[:column_id]).charge_staff_id && !@current_staff.is_type_editor_admin? && !@current_staff.authority_of_common?
  end

  def redirect_to_parent_column_performance_log
    column = Column.find(params[:column_id])
    unless column.parent_id.nil?
      flash[:notice] = "该频道没有数据"
      if params[:action] == 'news_index'
        redirect_to news_index_console_column_column_performance_logs_url(Column.where(:id => column.parent_id).first)
      elsif params[:action] == 'common_index'
        redirect_to common_index_console_column_column_performance_logs_url(Column.where(:id => column.parent_id).first)
      end
    end
  end
end
