class ColumnPerformanceLog < ActiveRecord::Base

  belongs_to :column

  attr_accessible :parent_column_id, :date_at, :post_count, :click_count, :staff_id, :column_id

  def average_hits
    post_count == 0 ? 0 : sprintf("%.1f", click_count / post_count.to_f)
  end

  class << self

    def find_by_month(column)
      ColumnPerformanceLog.find_by_sql(["select CONCAT(YEAR(date_at), '-', MONTH(date_at)) date_index, 
                                                id, sum(post_count) post_count, sum(click_count) click_count
                                         from column_performance_logs
                                         where column_id = ?
                                         group by date_index", column])
    end

  end

end