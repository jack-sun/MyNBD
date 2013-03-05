#encoding:utf-8
require 'rubygems'
namespace :database do

  task :patch_mn_accounts_gift_details => :environment do
    puts "patch begin"
    
    index = 1
    MnAccount.find_each(:batch_size => 100, :conditions => "plan_type = -1 AND gift_details is null")  do |account|
      puts "begin #{index}-----------"
      MnAccount.update_all(["gift_details = ?", "赠送7天"], ["id = ?", account.id])

      puts "----finish #{index = index+1}------"
    end

    puts "patch done"
  end

end
