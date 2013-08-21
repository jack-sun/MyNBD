#encoding: utf-8
require "spreadsheet"
require 'fileutils'
module Nbd::MobileNewspaperAccountXls
  def write_file(accounts_array, file_name)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    accounts_array.each_with_index do |account, index|
      sheet1.row(index).concat account
    end
    sheet1.column(0).width = 30
    sheet1.column(1).width = 30

    FileUtils.mkdir_p("#{Rails.root}/bak_files/mobile_newspaper_service_cards/#{Time.now.strftime("%Y-%m-%d")}")
    book.write "#{Rails.root}/bak_files/mobile_newspaper_service_cards/#{Time.now.strftime("%Y-%m-%d")}/#{file_name}.xls"
  end

  def get_accounts_from_file(file)
    file = Spreadsheet.open(file) 
    sheet = file.worksheet 0
    accounts = []
    sheet.each_with_index do |row, index|
      accounts << [row[0], row[1], row[3]]
    end
    accounts
  end

  def generate_xls_for_card_task card_task
    book = Spreadsheet::Workbook.new
    card_task.card_sub_tasks.each do |card_sub_task|
      name = []
      name << card_sub_task.converted_service_card_type
      name << card_sub_task.converted_service_card_plan_type
      name << "#{card_sub_task.service_card_count}张"
      sheet = book.create_worksheet :name => name.join(" ")
      sheet.row(0).push "卡号", "密码", "类型", "套餐"
      card_sub_task.service_cards.each_with_index do |service_card, index|
        sheet.row(index + 1).push service_card.card_no, service_card.password, service_card.converted_card_type, service_card.converted_plan_type
      end
    end
    FileUtils.mkdir_p("#{Rails.root}/bak_files/mobile_newspaper_service_cards/#{Time.now.strftime("%Y-%m-%d")}")
    book.write "#{Rails.root}/bak_files/mobile_newspaper_service_cards/#{Time.now.strftime("%Y-%m-%d")}/#{card_task.created_at.strftime("%Y-%m-%d-%H-%M-%S")}_task#{card_task.id}_#{card_task.create_staff.real_name}.xls"
    return "#{Rails.root}/bak_files/mobile_newspaper_service_cards/#{Time.now.strftime("%Y-%m-%d")}/#{card_task.created_at.strftime("%Y-%m-%d-%H-%M-%S")}_task#{card_task.id}_#{card_task.create_staff.real_name}.xls"
  end
end
