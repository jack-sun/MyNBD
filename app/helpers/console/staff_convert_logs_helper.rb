module Console::StaffConvertLogsHelper
  def convert_count(work_log)
    work_log[:convert_count] ||= 0
  end

  def convert_count_nil?(work_log)
    work_log[:convert_count].nil?
  end

  def total_press_amount(work_log)
    work_log[:press_amount] + work_log[:convert_count] if work_log[:convert_count]
  end

  def convert_count_status(work_log)
    StaffConvertLog::STATUS[work_log[:status]]
  end

  def date_at
    params[:date].present? ? params[:date] : @staff_convert_log.date_at
  end

  def options_for_status
    options = []
    options << [StaffConvertLog::STATUS[StaffConvertLog::PENDING], StaffConvertLog::PENDING]
    options << [StaffConvertLog::STATUS[StaffConvertLog::APPROVED], StaffConvertLog::APPROVED]
    return options
  end
end
