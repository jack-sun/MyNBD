#encoding:utf-8
require "spreadsheet"
require 'fileutils'
require 'nbd/mobile_newspaper_account_xls'
class Console::Premium::ServiceCardsController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_mobile_newspaper_console

  include Nbd::MobileNewspaperAccountXls

  def index
    @stats_type = params[:type] || "0"
    @service_card_type = "manage"
    if @stats_type == "0"
      @service_cards = ServiceCard.where(:status => @stats_type).order("card_no desc").includes(:staff).page(params[:page]).per(30)
    else
      @service_cards = ServiceCard.where(:status => @stats_type).order("card_no desc").includes({:payment => :user}).page(params[:page]).per(30)
    end
  end

  def new
    @service_card_type = "create"
  end

  def create
    count = params[:count].to_i
    card_type = params[:type].to_i
    accounts = []
    accounts[0] = ["卡号", "密码", "套餐类型", "套餐编码"]
    temp = ServiceCard.init_temp_new_card(count)

    temp.sort_by(&:first).each_with_index do |account, index|
      accounts << [format_service_card(account.first.to_s), format_service_card(account.last.to_s), "#{ServiceCard::TIME_TYPE[card_type]}个月", card_type]
    end

    @file_name = "#{Time.now.strftime("%Y-%m-%d-%H-%M")}-#{@current_staff.name}"
    @count = params[:count].to_i
    @service_card_type = "create"
    write_file(accounts, @file_name)

    return render :download
  end

  def download
  end

  def download_file
    name = params[:file_name]
    file_path = "#{Rails.root}/bak_files/mobile_newspaper_service_cards/#{name.split("-")[0..2].join("-")}/#{name}.xls"
    return send_file file_path
  end

  def upload
    @service_card_type = "manage"
    accounts = get_accounts_from_file(params[:accounts_file].tempfile)
    card_nos = ServiceCard.select(:card_no).map(&:card_no)
    accounts.shift
    accounts.each do |account|
      card_no = account[0].gsub(" ", "")
      password = account[1].gsub(" ", "")
      next if card_nos.include?(card_no)
      card = @current_staff.service_cards.create(:card_no => card_no, :password => password, :card_type => account[2].to_i)
      card_nos << card.card_no
    end
    redirect_to console_premium_service_cards_url    
  end

  def upload_file
    @service_card_type = "manage"
  end

end
