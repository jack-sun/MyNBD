#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
require 'spreadsheet'

namespace :koubeibang do

  ##### rake koubeibang:import_kbb_votes_candidates file_path='xxx.xls' kbb_id=xxx
  desc "import koubeibang candidates for vote options"
  task :import_kbb_votes_candidates => :environment do
    file_path = ENV['file_path'].to_s
    kbb_id = ENV['kbb_id']

    puts "="*6 + "导入口碑榜投票候选提名" + "="*6 

    Spreadsheet.client_encoding = 'UTF-8'
    file = Spreadsheet.open(file_path)
    worksheets = file.worksheets
    count = {:done => 0, :exsited => 0, :failed => 0}
    kbb = Koubeibang.where(:id => kbb_id).first
    if kbb
      KoubeibangCandidate.transaction do
        worksheets.each_with_index do |sheet, index|
          sheet.each_with_index do |row, row_index|
            next if row_index == 0 #忽略第一行标题
            stock_code = (row[0] || "").strip
            stock_company = (row[1] || "").strip
            comment = (row[2] || "").strip
            puts "stock_code: #{stock_code}，stock_company: #{stock_company}，comment：#{comment}"
            if stock_code.present? && stock_company.present?# && comment.present?
              if (kbb_candidate = kbb.koubeibang_candidates.where(:stock_code => stock_code)).blank?
                kbb_candidate = kbb.koubeibang_candidates.new(:stock_code => stock_code, :stock_company => stock_company, :kbb_id => kbb_id)
                kbb_candidate.save!
                count[:done] += 1
              else
                kbb_candidate.update_attributes!(:stock_company => stock_company)
                count[:exsited] += 1
              end
              kbb_candidate_detail = kbb_candidate.koubeibang_candidate_details.new(:comment => comment, :remote_ip => '127.0.0.1')
              kbb_candidate_detail.save!
              puts "成功"
            else
              count[:failed] += 1
              puts "失败" 
            end
          end
        end
      end
    else
      puts "无效的kbb_id"
    end

    puts "="*6 + "导入口碑榜投票候选提名" + "="*6 
    puts "*"*6 + "本次导入报告" + "*"*6
    puts "已完成: #{count[:done]}"
    puts "存在: #{count[:exsited]}"
    puts "失败: #{count[:failed]}"
  end

end

