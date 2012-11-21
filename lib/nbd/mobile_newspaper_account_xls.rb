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
end
