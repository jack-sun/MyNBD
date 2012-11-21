#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
require 'spreadsheet'
namespace :poll do
  task :import_options_for_jiujiuai => :environment do
    # '玖玖爱' 投票导入
    
    poll_id = ENV['poll_id'].to_i
    puts "poll_id: #{poll_id}"
    
    file_path = ENV['file_path'].to_s
    puts "file_path: #{file_path}"
    
    Spreadsheet.client_encoding = 'UTF-8'

    file = Spreadsheet.open(file_path)

    sheet = file.worksheet 0
    count = 1
    
    sheet.each do |row|
      puts "=============current count: #{count}============"
      name, phone, words = row
      phone = if phone.present? 
        p = phone.to_s.gsub(/\.0/, '')
        p[-7..-4] = "****"
        p
      else
        ''
      end
      
      content = "#{words} (#{phone} #{name})"
      puts content
      
      pos = 1
      poll = Poll.find(poll_id)
      poll.polls_options.create(:pos => pos, :content => content)
      pos += 1
      
      count += 1
    end

    puts "===============DONE==================="
  end
end

