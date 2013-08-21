#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
require 'spreadsheet'
namespace :koubeibang do
  task :import_kbb_accounts_2013_08_12 => :environment do
    
    
    file_path = ENV['file_path'].to_s
    target_file_path = String.new file_path
    target_file_path.insert(-5, '_result')
    puts "file_path: #{file_path}"
    puts "===============导入口碑榜机构==================="
    Spreadsheet.client_encoding = 'UTF-8'

    file = Spreadsheet.open(file_path)
    worksheets = file.worksheets

    count = {done: 0, failed: 0, exsited: 0}
    worksheets.each_with_index do |sheet, index|

      sheet.each_with_index do |row, row_index|
        next if row_index == 0 #忽略第一行标题

        name = (row.first || "").strip
        inviter = (row[3] || "").strip
        next if name.blank?

        koubeibangAccount = KoubeibangAccount.create(:company_name => name, :inviter => inviter)
        unless koubeibangAccount.new_record?
          puts "新增： #{name} 口碑榜机构 成功"
          count[:done] += 1
          sheet.row(row_index)[1] = koubeibangAccount.name
          sheet.row(row_index)[2] = koubeibangAccount.password
        else
          puts "新增： #{name} 口碑榜机构 成功 失败" 
          count[:failed] += 1
        end
      end
    end

    file.write target_file_path

    puts "="*6 + "导入口碑榜机构已完成" + "="*6 
    puts "*"*6 + "本次导入报告" + "*"*6
    puts "已完成: #{count[:done]}"
    puts "失败: #{count[:failed]}"
  end
end

