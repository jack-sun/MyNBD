#encoding: utf-8
class StaffPerformanceLog < ActiveRecord::Base

  belongs_to :staff
  belongs_to :review_staff, :foreign_key => "review_staff_id", :class_name => "Staff"

  attr_accessible :staff_id, :date_at, :post_count, :click_count, :convert_count, :convert_count_reviewed, :review_staff_id, :convert_apply_comment

  UNREVIEW = 0
  REVIEWED = 1
  REVIEW_STATUS = {UNREVIEW => "待审核", REVIEWED => "已通过"}

  validates :convert_count, :numericality => true, :presence => true
  validates :convert_count_reviewed, :inclusion => { :in => StaffPerformanceLog::REVIEW_STATUS.keys }, 
                                     :presence => true

  def self.get_performance_logs(staff_id, find_method)
    return StaffPerformanceLog.where(:staff_id => staff_id).order('date_at DESC') if find_method == 'day'
    if find_method == 'month'
        return StaffPerformanceLog.find_by_sql(["select CONCAT(YEAR(date_at), '-', MONTH(date_at)) date_index, sum(click_count) click_count, sum(sub_table.convert_count) convert_count, sum(post_count) post_count
                                                from staff_performance_logs
                                                left join (
                                                  select id, sum(convert_count) convert_count from staff_performance_logs
                                                  where staff_performance_logs.staff_id = ? and
                                                  staff_performance_logs.convert_count_reviewed = 1
                                                ) sub_table
                                                on sub_table.id = staff_performance_logs.id
                                                where staff_performance_logs.staff_id = ?
                                                group by date_index", staff_id, staff_id])
    end
  end

  def reviewed?
    self.convert_count_reviewed == StaffPerformanceLog::REVIEWED
  end

  def average_hits
    return self.click_count / self.post_count.to_f if post_count != 0
    return 0
  end

  def total_press_count
    post_count + (reviewed? ? convert_count : 0)
  end
end
