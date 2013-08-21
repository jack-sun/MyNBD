#encoding:utf-8
require 'rubygems'
require 'nbd/utils'
require 'spreadsheet'

namespace :touzibao do
  task :export_payment_account_nickname => :environment do
    file_path = ENV['file_path'].to_s
    puts "file_path: #{file_path}"
    puts "===============开始读取数据==================="
    Spreadsheet.client_encoding = 'UTF-8'
    file = Spreadsheet.open(file_path)
    worksheets = file.worksheets

    successed_counter = 0
    from_taobao_counter = 0
    have_no_account_counter = 0

    worksheets.each_with_index do |sheet, index|
      sheet.each_with_index do |row, row_index|
        row[10] = "用户昵称" if row_index == 1
        if row_index > 1
          payment_trade_no = row[1]
          payment_id = payment_trade_no.split('_').last if payment_trade_no.index('live') == 0
          payment = Payment.where('id = ?',payment_id).first
          if payment && payment.service && payment.service.user 
            nickname = payment.service.user.nickname
            puts "添加昵称：#{nickname}"
            successed_counter += 1
          else
            if payment.nil?
              puts "#{row_index} 来自淘宝购物......"
              from_taobao_counter += 1
            else
              puts "#{row_index} 该订单没有每经帐号！"
              have_no_account_counter += 1
            end  
            nickname = ""
          end
          row[10] = nickname
        end
      end
    end

    file.write "result.xls"
    puts "\n添加昵称：#{successed_counter}个"
    puts "来自淘宝购物：#{from_taobao_counter}个"
    puts "没有每经帐号：#{have_no_account_counter}个"
    puts "===============END==================="
  end
end