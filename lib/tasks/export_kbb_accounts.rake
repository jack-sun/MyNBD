#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
require 'spreadsheet'
namespace :koubeibang do
  task :export_kbb_accounts => :environment do
    
    
    file_path = ENV['file_path'].to_s
    target_file_path = String.new file_path
    target_file_path.insert(-5, '_result')
    puts "file_path: #{file_path}"
    puts "===============导入口碑榜机构==================="
    Spreadsheet.client_encoding = 'UTF-8'

    file = Spreadsheet.open(file_path)
    worksheets = file.worksheets

    count = {done: 0, failed: 0, exsited: 0}

    id ||= 54
    kbb_account = KoubeibangAccount.find(id)
    worksheets.each_with_index do |sheet, index|
      sheet.each_with_index do |row, row_index|
        fill_with_kbb_account(kbb_account, row, row_index, sheet)
        # p row
        # next if row_index == 0 #忽略第一行标题

        # name = (row.first || "").strip
        # inviter = (row[2] || "").strip
        # next if name.blank?

        # koubeibangAccount = KoubeibangAccount.new(:name => name, :inviter => inviter)
        # koubeibangAccount.generate_salt
        # koubeibangAccount.generate_rand_password(:name, 6)
        # if koubeibangAccount.save!
        #   puts "新增： #{name} 口碑榜机构 成功"
        #   count[:done] += 1
        #   sheet.row(row_index)[1] = koubeibangAccount.password
        # else
        #   puts "新增： #{name} 口碑榜机构 成功 失败" 
        #   count[:failed] += 1
        # end
      end
      break if index == 0
    end

    file.write target_file_path

    # puts "="*6 + "导入口碑榜机构已完成" + "="*6 
    # puts "*"*6 + "本次导入报告" + "*"*6
    # puts "已完成: #{count[:done]}"
    # puts "失败: #{count[:failed]}"
  end

  def fill_with_kbb_account(kbb_account, row, row_index, sheet)
    fill_basic_info(kbb_account, row, row_index, sheet) if row_index < 13
    fill_votes(kbb_account, row, row_index, sheet) if row_index > 13
  end

  def fill_basic_info(kbb_account, row, row_index, sheet)
    current = sheet.row(row_index)[0]
    current ||= ""
    content = case row_index
    when 3
        kbb_account.company_name
    when 4
        kbb_account.real_name
    when 5
        kbb_account.phone_no
    when 6
        kbb_account.email
    when 7
        kbb_account.inviter
    when 8
        kbb_account.created_at.strftime("%Y-%m-%d %h:%M")
    end
    sheet.row(row_index)[0] = "#{current}#{content}"
  end

  def fill_votes(kbb_account, row, row_index, sheet)
    # current = sheet.row(row_index)[0]
    # current ||= ""

    if row_index == 15
        koubeibang_candidate_ids = Koubeibang.first.koubeibang_candidates.map(&:id)
        koubeibangVotes = kbb_account.koubeibang_votes.where(:kbb_candidate_id => koubeibang_candidate_ids)
        koubeibangVotes.each_with_index do |koubeibangVote, index|
            candidate = koubeibangVote.koubeibang_candidate
            sheet.row(row_index+index)[0] = "#{candidate.stock_code}--#{candidate.stock_company}"
        end
    end
  end  
end

