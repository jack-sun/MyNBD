#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :touzibao do
  task :export_touzibao_accounts => :environment do
   
    # export place
    file_path = ENV['file_path'].to_s
    puts "file_path: #{file_path}"
    
    raw_result = Spreadsheet::Workbook.new
    sheet = raw_result.create_worksheet
    
    sheet.row(0).concat ['用户名', '邮箱', '手机号', '套餐类型', '状态']

    overdue_str_h = {true => "已过期", false => "有效"}

    touzibao_accounts = MnAccount.order("id desc").each_with_index do|account, row_index|
      begin
        puts "-------------#{row_index}------------"
        user = account.user
        next unless user.present?

        [user.nickname, user.email, account.phone_no, MnAccount::PLAN_TYPE_NAMES[account.plan_type], overdue_str_h[account.overdue?]].each_with_index do|value, column_index|
          sheet.row(row_index+1)[column_index] = value
        end

      rescue
        puts $!
        return
      end
    end
    
    sheet.column(0).width = 15
    sheet.column(1).width = 20
    sheet.column(2).width = 12
    sheet.column(3).width = 10
    sheet.column(4).width = 5

    raw_result.write file_path
    puts "=====================DONE========================"
  end
end


