class Jobs::RefreshStaffAndColumnPerformanceLogsData
  @queue = :performance_log
  def self.perform
    puts "======refresh staff performance log data begin======"
    staff_ids = Staff.select(:id).where({:status => Staff::STATUS_ACTIVE, :user_type => Staff::TYPE_EDITOR})
    staff_ids.each do |staff_id|
      staff_performance_logs = Article.find_by_sql(["select date_format(articles.created_at,'%Y-%m-%d') date_at, 
                                                            count(*) post_count, 
                                                            sum(click_count) click_count
                                                     from articles, articles_staffs 
                                                     where articles.id = articles_staffs.article_id 
                                                     and articles.status = 1
                                                     and articles_staffs.staff_id = ?
                                                     and articles.created_at > ?
                                                     group by date_at;", staff_id.id, Date.current.beginning_of_month])
      unless staff_performance_logs.empty?
        staff_performance_logs.each do |staff_performance_log|
          if staff_performance_log.date_at == (Date.current - 1).to_s
            StaffPerformanceLog.create!(:date_at => staff_performance_log.date_at, 
                                        :post_count => staff_performance_log.post_count, 
                                        :click_count => staff_performance_log.click_count, 
                                        :staff_id => staff_id.id)
          else
            temp_log = StaffPerformanceLog.where(:date_at => staff_performance_log.date_at, :staff_id => staff_id.id).first
            temp_log.update_attributes(:post_count => staff_performance_log.post_count, 
                                       :click_count => staff_performance_log.click_count)
          end
          puts "update staff: #{staff_id.id} #{staff_performance_log.date_at} staff_performance_log"
        end
      end
    end
    puts "======refresh staff performance log data done======"

    puts "======refresh column performance log data begin======"
    column_ids = Column.select(:id).basic_columns
    column_ids.each do |column_id|
      column_performance_logs = Column.find_by_sql(["select sum(articles.click_count) click_count,
                                                            count(*) post_count,
                                                            date_format(articles.created_at,'%Y-%m-%d') date_at
                                                     from articles, articles_columns
                                                     where articles.status = 1
                                                     and articles.id = articles_columns.article_id
                                                     and articles.created_at > ?
                                                     and articles_columns.column_id in (
                                                       select id from columns where parent_id = ? and status = 1
                                                     )
                                                     group by date_at", column_id.id, Date.current.beginning_of_month])
      unless column_performance_log.empty?
        column_performance_logs.each do |column_performance_log|
          if staff_performance_log.date_at == (Date.current - 1).to_s
            ColumnPerformanceLog.create!(:date_at => column_performance_log.date_at, 
                                         :post_count => column_performance_log.post_count, 
                                         :click_count => column_performance_log.click_count, 
                                         :column_id => column_id.id,
                                         :parent_column_id => 0)
          else
            temp_log = ColumnPerformanceLog.where(:date_at => column_performance_log.date_at, :column_id => column_id.id).first
            temp_log.update_attributes(:post_count => column_performance_log.post_count, 
                                       :click_count => column_performance_log.click_count)
          end
          puts "update column: #{column_id.id} #{column_performance_log.date_at} column_performance_log"
        end
      end
    end
    puts "======refresh column performance log data done======"
  end
end