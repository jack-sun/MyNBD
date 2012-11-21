#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :poll do
  task :export_poll_result_for_jiujiuai => :environment do
   
    # target poll
    poll_id = ENV['poll_id'].to_i
    puts "poll_id: #{poll_id}"
    
    # export place
    file_path = ENV['file_path'].to_s
    puts "file_path: #{file_path}"
    
    raw_result = Spreadsheet::Workbook.new
    sheet = raw_result.create_worksheet
    
    poll = Poll.find(poll_id)
    poll.polls_options.order("vote_count DESC").each_with_index do|option, index|
      begin
        puts "-------------#{index}------------"
        content, contact = option.content.split("(")
        
        puts "content: #{content} \n"
        puts "contact #{contact} \n"
        content = content.strip
        phone, name = contact.gsub(")", "").split(" ")
      
        [option.content, name, phone, content, option.vote_count].each_with_index do|value, r_index|
          sheet.row(index)[r_index] = value
        end
        
      rescue
        puts $!
        return
      end
    end
    
    raw_result.write file_path
    
    puts "=====================DONE========================"
  end
end

