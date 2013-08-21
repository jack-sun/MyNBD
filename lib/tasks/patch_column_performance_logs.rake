#encoding:utf-8
require 'rubygems'
namespace :database do
  task :patch_column_performance_logs => :environment do
    puts "======patch begin======"
    column_ids = Column.select(:id).basic_columns
    column_ids.each do |column_id|
      column_performance_logs = Column.find_by_sql(["select sum(articles.click_count) click_count,
                                                            count(*) post_count,
                                                            date_format(articles.created_at,'%Y-%m-%d') date_at
                                                     from articles, articles_columns
                                                     where articles.status = 1
                                                     and articles.id = articles_columns.article_id
                                                     and articles.created_at > '2013-01-01'
                                                     and articles_columns.column_id in (
                                                       select id from columns where parent_id = ? and status = 1
                                                     )
                                                     group by date_at", column_id.id])
      column_performance_logs.each do |column_performance_log|
        ColumnPerformanceLog.create(:date_at => column_performance_log.date_at, 
                                    :post_count => column_performance_log.post_count, 
                                    :click_count => column_performance_log.click_count, 
                                    :column_id => column_id.id,
                                    :parent_column_id => 0)
        puts "add column: #{column_id.id} #{column_performance_log.date_at} column_performance_log"
      end
    end
    puts "======patch done======"
  end
end
