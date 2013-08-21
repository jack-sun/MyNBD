#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
require 'spreadsheet'
namespace :article do
  task :import_keywords => :environment do
    
    
    file_path = ENV['file_path'].to_s
    puts "file_path: #{file_path}"
    puts "===============开始导入敏感词汇==================="
    Spreadsheet.client_encoding = 'UTF-8'

    file = Spreadsheet.open(file_path)
    worksheets = file.worksheets

    count = {done: 0, failed: 0, exsited: 0}
    worksheets.each_with_index do |sheet, index|

      sheet.each_with_index do |row, row_index|
        next if row_index == 0 #忽略第一行标题

        value = (row.first || "").strip
        next if value.blank?

        badword = Badword.new(value: value, level: 0, staff_id: 11)
        unless badword.record_exsit?
          if badword.save!
            puts "新增： #{badword.value} 敏感词成功"
            count[:done] += 1
          else
            puts "新增： #{badword.value} 敏感词失败" 
            count[:failed] += 1
          end
        else
          puts "警告：#{badword.value} 敏感词已存在"
          count[:exsited] += 1
        end
      end
    end

    puts "="*6 + "导入敏感词已完成" + "="*6 
    puts "*"*6 + "本次导入报告" + "*"*6
    puts "已完成: #{count[:done]}"
    puts "失败: #{count[:failed]}"
    puts "已存在: #{count[:exsited]}"
  end
end

