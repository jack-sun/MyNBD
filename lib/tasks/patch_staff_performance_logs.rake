#encoding:utf-8
require 'rubygems'
namespace :database do
  task :patch_staff_performance_logs => :environment do
    puts "======patch begin======"
    staff_ids = Staff.select(:id).where({:status => Staff::STATUS_ACTIVE, :user_type => Staff::TYPE_EDITOR})
    staff_ids.each do |staff_id|
      staff_performance_logs = Article.find_by_sql(["select date_format(articles.created_at,'%Y-%m-%d') date_at, 
                                                            count(*) post_count, 
                                                            sum(click_count) click_count 
                                                     from articles, articles_staffs 
                                                     where articles.id = articles_staffs.article_id 
                                                     and articles.status = 1
                                                     and articles.created_at > '2013-01-01'
                                                     and articles_staffs.staff_id = ?
                                                     group by date_at;", staff_id.id])
      staff_performance_logs.each do |staff_performance_log|
        StaffPerformanceLog.create(:date_at => staff_performance_log.date_at, 
                                   :post_count => staff_performance_log.post_count, 
                                   :click_count => staff_performance_log.click_count, 
                                   :staff_id => staff_id.id)
        puts "add staff: #{staff_id.id} #{staff_performance_log.date_at} staff_performance_log"
      end
    end
    puts "======patch done======"
  end
end
