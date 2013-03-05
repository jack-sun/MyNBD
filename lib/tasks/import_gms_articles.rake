#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
require 'spreadsheet'
namespace :touzibao do
  task :import_gms_articles => :environment do
    
    
    file_path = ENV['file_path'].to_s
    puts "file_path: #{file_path}"
    
    Spreadsheet.client_encoding = 'UTF-8'

    file = Spreadsheet.open(file_path)
    worksheets = file.worksheets
    page = 1
    count = 1
    worksheets.each do |sheet|
      is_work = false
      # gmss = []
      # articles = []
      column = Column.find(Column::GMS_ARTICLES_COLUMN)
      staff = Staff.find(196)
      sheet.each do |row|
        if is_work
          article_params = {}
          gms_params = {}
          orgin_code, stock_name, title, meeting_at, credits = row
          stock_code = "#{'0'*(6-code.to_s.length)}#{code.to_s}"
          gms_params = {:stock_code => stock_code, 
                        :stock_name => stock_name, 
                        :meeting_at => meeting_at, 
                        :status => 1, 
                        :is_preview => 1}
          article_params = {:status => 1, 
                            :column_ids => ["210"], 
                            :title => "#{gms_params[:stock_name]} 2012年股东大会实录", 
                            :pages_attributes => {"0" => {"content" => "<p>实录将在股东大会召开后更新，请密切关注公司股东大会召开日期</p>"}}}
          Staff.transaction do
            staff.create_gms_article(gms_params, article_params)
            column.update_attribute(:max_pos,column.max_pos + 1)
            puts "保存 #{gms_params[:stock_code]},完成#{count}个,当前是第#{page}页"
          end
          count += 1
        else
          is_work = true
        end
      end
      page +=1
    end
    puts "===============完成！一共保存了#{count}篇股东大会实录==================="
  end
end

