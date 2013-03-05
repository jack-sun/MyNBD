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
      @service_cards = ServiceCard.where(:status => @stats_type).order("id desc").includes(:staff).page(params[:page]).per(30)
    else
      @service_cards = ServiceCard.where(:status => @stats_type).order("id desc").includes({:payment => :user}).page(params[:page]).per(30)
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
      card_no, card_password = account
      accounts << [format_service_card(card_no.to_s), card_password.to_s, "#{ServiceCard::TIME_TYPE[card_type]}个月", card_type]
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

    exist_cards = ServiceCard.select([:card_no, :password]) 
    cards_infos = {}
    exist_cards.each{|card| cards_infos.merge!({card.card_no => card.password})}

    accounts.shift
    accounts.each do |account|
      card_no = account[0].to_s.gsub(" ", "")
      password = account[1].to_s.gsub(" ", "")
      card_type = account[2].to_i

      next if cards_infos.has_key?(card_no) or cards_infos.has_value?(password)
      
      card = @current_staff.service_cards.create(:card_no => card_no, 
                                                 :password => password, 
                                                 :card_type => card_type)
      cards_infos.merge!({card_no => password})
    end

    redirect_to console_premium_service_cards_url    
  end

  def upload_file
    @service_card_type = "manage"
  end

  def search
    @service_cards = ServiceCard.where("card_no like ?","%#{params[:cards_no].split.join}%").includes(:staff).page(params[:page]).per(30)
  end

end
