module Console::StaffPerformanceLogsHelper

  # def console_staff_show_articles_helper_path(staff_name, log_date)  
  #   return news_show_articles_console_staff_url(staff_name, log_date) if @console == 'news'
  #   return show_articles_console_staff_url(staff_name, log_date) if @console == 'common'
  # end

  def total_press_count(performance_log)
    if @find_method == 'day'
      return performance_log.total_press_count
    elsif @find_method == 'month'
      return performance_log[:post_count] + performance_log[:convert_count]
    end
        
  end

  def date_at
    params[:date].present? ? params[:date] : @staff_convert_log.date_at
  end

  def review_status_name(performance_log)
    StaffConvertLog::STATUS[performance_log.convert_count_reviewed]
  end

  def average_hits(performance_log)
    if @find_method == 'day'
      return format_average_hits performance_log.average_hits
    elsif @find_method == 'month'
      return format_average_hits performance_log[:click_count] / total_press_count(performance_log).to_f
    end
  end

  def format_average_hits(average_hits)
    return sprintf("%.1f", average_hits)
  end
end
