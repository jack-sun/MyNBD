#encoding:utf-8
require 'rubygems'
require 'nbd/utils'
namespace :touzibao do
  task :fetch_failed_verify_payments_created_from_appstore => :environment do
    include Premium::PremiumUtils

    log_path = ENV["log_path"].to_s
    # log_path = 'log/fetch_test.out'
    puts "log_path: #{log_path}" 

    faild_payments = Payment.where("status <> 1 AND receipt_data is not null").order('id asc')

    # success_payments = Payment.where("status = 1 AND receipt_data is not null").order('id asc')

    # puts "success_payments_size:#{success_payments.size}======faild_payments_size:#{faild_payments.size}"
    failed_verify_payments = []

    faild_payments.each_with_index do |payment, index|
      index = index + 1

      result = {}
      result = verify_apple_puchase(payment.receipt_data)
      verify_assert = (result["type"].to_i == payment.plan_type.to_i and result["status"].to_i == 0)
      unless verify_assert
        failed_verify_payments << {:payment_id => payment.id, 
                                   :user_id => payment.user_id, 
                                   :service_id => payment.service_id,
                                   :plan_type => payment.plan_type,
                                   :plan_type_name => MnAccount::PLAN_TYPE_NAMES[payment.plan_type],
                                   :status => result["status"],
                                   :payment_at => payment.payment_at.present? ? payment.payment_at.strftime('%Y-%m-%d %H:%M:%S') : nil
                                  }
      end

      display_verify = verify_assert ? 'success' : 'failed'

      # File.open(log_path, 'a') do |f|
      #   f.puts "--------------#{index} #{display_verify}-------------"
      #   f.puts "payment id: #{payment.id}"
      #   f.puts result.inspect
      #   f.puts "verify result: " + display_verify
      # end

      puts "--------#{index} #{display_verify}------"

      sleep 1 
    end

    puts "failed_verify_payments:#{failed_verify_payments}"

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1.row(0).concat ['payment_id', 'user_id', 'service_id', 'plan_type', 'plan_type_name' 'status', 'payment_at']
    failed_verify_payments.each_with_index do |payment, index|
      puts "index:#{index}====payment:#{payment.inspect}"
      sheet1.row(index+1).concat [payment[:payment_id], payment[:user_id], payment[:service_id], payment[:plan_type], payment[:plan_type_name], payment[:status], payment[:payment_at]]
    end
    FileUtils.mkdir_p("#{Rails.root}/tmp/fetch_test")
    book.write "#{Rails.root}/tmp/fetch_test/out.xls"    

    File.open(log_path, 'a') do |f|
      f.puts "========failed payments below, Total count: #{failed_verify_payments.size}========="
      failed_verify_payments.each do|p|
        f.puts p.inspect + "\n"
      end
      f.puts "========failed payments above========="
    end

    puts "Done!"

  end
end

