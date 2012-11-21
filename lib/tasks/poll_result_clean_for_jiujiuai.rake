#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :poll do
  task :poll_result_clean_for_jiujiuai => :environment do
    # use this task to fetch full phone num.
    
    # ori file path
    ori_file_path = ENV['ori_file_path'].to_s
    puts "from_file_path #{ori_file_path}"
    
    # raw file path
    raw_file_path = ENV['raw_file_path'].to_s
    puts "to_file_path #{raw_file_path}"
    
    # raw file path
    result_file_path = ENV['result_file_path'].to_s
    puts "result_file_path #{result_file_path}"
    
    
    Spreadsheet.client_encoding = 'UTF-8'
    
    origin_file_sheet = Spreadsheet.open(ori_file_path).worksheet 0
    
    orgin_data = {}
    origin_file_sheet.each do |row|
      name, phone, words = row
      orgin_data[name.gsub(/\s+/, "")] = phone if name.present?
    end
    
    #puts "orgin_data: #{orgin_data.inspect}"
    
    puts "==================init orgin data done========================"
    
    result_file = Spreadsheet::Workbook.new
    result_sheet = result_file.create_worksheet
    
    raw_file_sheet = Spreadsheet.open(raw_file_path).worksheet 0
    raw_file_sheet.each_with_index do |row, index|
      
      
      content, name, raw_phone, words, vote_count = row[0], row[1], row[2], row[3], row[4]
      phone = row[1].present? ? orgin_data[row[1].gsub(/\s+/, "")] : ""
      
      [content, name, raw_phone, phone, words, vote_count].each_with_index do|value, r_index|
        result_sheet.row(index)[r_index] = value
      end
    
      
    end
    
    result_file.write result_file_path
    puts "=====================DONE========================"
    
  end
end

