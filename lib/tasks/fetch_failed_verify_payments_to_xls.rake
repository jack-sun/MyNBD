#encoding:utf-8
require 'rubygems'
require 'nbd/utils'
require "spreadsheet"
require 'fileutils'
namespace :touzibao do
  task :fetch_failed_verify_payments_to_xls => :environment do
    include Premium::PremiumUtils
    file_path = ENV['file_path'].to_s
    puts "file_path:#{file_path}"
    payments = Payment.where("receipt_data is not null AND payment_at between '2012-12-17' AND '2013-3-11'").order('id asc')
    puts "total payments count:#{payments.size}======"
    failed_verify_payments = []
    success_verify_payments = []
    payments.each_with_index do |payment, index|
      index = index + 1

      result = {}
      result = verify_apple_puchase(payment.receipt_data)
      verify_assert = (result["type"].to_i == payment.plan_type.to_i and result["status"].to_i == 0)
      payment = {:payment_id => payment.id, 
                                   :user_id => payment.user_id, 
                                   :service_id => payment.service_id,
                                   :plan_type => payment.plan_type,
                                   :plan_type_name => MnAccount::PLAN_TYPE_NAMES[payment.plan_type],
                                   :status => result["status"],
                                   :payment_at => payment.payment_at.present? ? payment.payment_at.strftime('%Y-%m-%d %H:%M:%S') : nil
                                  }
      unless verify_assert
        failed_verify_payments << payment
      else                                  
        success_verify_payments << payment
      end
      puts "=====verifying payment_id:#{payment[:payment_id]}=====verify_assert:#{verify_assert ? 'success' : 'failed'}==="
      sleep 1 
    end


    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1.row(0).concat ['payment_id', 'user_id', 'service_id', 'plan_type', 'plan_type_name', 'status', 'payment_at']
    failed_verify_payments.each_with_index do |payment, index|
      sheet1.row(index+1).concat [payment[:payment_id], payment[:user_id], payment[:service_id], payment[:plan_type], payment[:plan_type_name], payment[:status], payment[:payment_at]]
    end

    sheet2 = book.create_worksheet
    sheet2.row(0).concat ['payment_id', 'user_id', 'service_id', 'plan_type', 'plan_type_name', 'status', 'payment_at']
    success_verify_payments.each_with_index do |payment, index|
      sheet2.row(index+1).concat [payment[:payment_id], payment[:user_id], payment[:service_id], payment[:plan_type], payment[:plan_type_name], payment[:status], payment[:payment_at]]
    end    
    book.write "#{file_path}.xls"    

  end
end

