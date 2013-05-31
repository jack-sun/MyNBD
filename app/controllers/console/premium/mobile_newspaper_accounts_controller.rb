#encoding:utf-8
require 'fileutils'
class Console::Premium::MobileNewspaperAccountsController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_mobile_newspaper_console
  def index
    @stats_type = params[:type] || "active"
    @filter_type = (params[:filter] || (@stats_type == "all" ? "1" : "3")).to_i

    @result = ::MnAccount
    @mn_mobile_type = @stats_type
    @result = case @stats_type
              when "active"
                @result.active
              when "invalid_soon"
                @result.invalid_soon(@filter_type.days)
              when "all"
                case @filter_type
                when 1, 7
                  @result.new_active(@filter_type.days)
                when 0
                  @result.invalid
                end
              end
    @result = @result.includes(:user).order("last_payment_at desc").page(params[:page]).per(30)
  end

  def appstore_users
    @mn_mobile_type = "appstore_users"
    @stats_type = params[:type].nil? ? Payment::STATUS_ALL : params[:type].to_i
    @payments = Payment.appstore
    @payments = @payments.verify_status(@stats_type) if @stats_type != Payment::STATUS_ALL
    @payments = @payments.includes(:user,:service).order("created_at DESC").page(params[:page]).per(30)
  end

  def plain
    @stats_type = params[:type] || "active"
    @filter_type = (params[:filter] || (@stats_type == "all" ? "1" : "3")).to_i

    @result = ::MnAccount
    @result = case @stats_type
              when "active"
                @result.active
              when "invalid_soon"
                @result.invalid_soon(@filter_type.days)
              end.select([:id, :phone_no])
    result_str = @result.map do |mn_account|
      mn_account.phone_no
    end.uniq.join("\n")

    dir_str = "#{Rails.root}/bak_files/accounts_records/#{Time.now.strftime("%Y-%m-%d")}"
    file_name = "accounts-#{@stats_type}-#{@filter_type}.txt"
    file_path = "#{dir_str}/#{file_name}"

    FileUtils.mkdir_p(dir_str)
    file = File.new(file_path, "w+")
    file.write result_str
    file.close

    if @stats_type == "active"
      @result.update_all(:last_sended_at => Time.now)
      account_record = ::ActivatedUserRecord.where(["created_at > ?", Time.now.beginning_of_day]).first
      if account_record
        account_record.update_attributes({:count => @result.count, :staff_id => @current_staff.id})
      else
        ::ActivatedUserRecord.create({:count => @result.count, :staff_id => @current_staff.id, :file_name => file_name})
      end
    end

    return send_file file_path, :filename => "每经网手机报有效用户-#{Time.now.strftime("%Y-%m-%d")}.txt"
  end

  def search
    @stats_type = params[:type] || "active"
    @filter_type = (params[:filter] || (@stats_type == "all" ? "1" : "3")).to_i

    @result = ::MnAccount
    @mn_mobile_type = @stats_type
    @result = case @stats_type
              when "active"
                @result.active
              when "invalid_soon"
                @result.invalid_soon(@filter_type.days)
              when "all"
                case @filter_type
                when 1, 7
                  @result.new_active(@filter_type.days)
                when 0
                  @result.invalid
                end
              end
    # search_str = "phone_no like '%#{params[:query]}%'"
    # @result = @result.where(search_str).includes(:user).order("last_payment_at desc").page(params[:page]).per(30)

    #edit by zhangbo at 2013.5.7 to add feature allow user search by username
    search_str = "mn_accounts.phone_no like '%#{params[:query]}%' or nickname like '%#{params[:query]}%'"
    @result = @result.joins(:user).where(search_str).order("last_payment_at desc").page(params[:page]).per(30)
    return render :index
  end

  def verify
    payment = Payment.find(params[:id])
    @stats_type = params[:type]
    Resque.enqueue(Jobs::VerifyApplePaymentJob, payment.id) if payment.present?
    return redirect_to appstore_users_console_premium_mobile_newspaper_accounts_url(:type => @stats_type)
  end

  def show
    @mn_account = MnAccount.includes(:user).where("id = ?", params[:id]).first
    @user = @mn_account.user
  end

  def update_password
    @mn_account = MnAccount.includes(:user).where("id = ?", params[:id]).first
    @user = @mn_account.user
    new_password = params[:account][:user][:password]
    if new_password.blank?
      @user.errors[:password] = "密码不能为空"
      return render :show
    end
    if @user.update_attributes(params[:account][:user])
      redirect_to console_premium_mobile_newspaper_account_url(@mn_account), :notice => "密码更改成功"
    else
      return render :show
    end
  end
end
