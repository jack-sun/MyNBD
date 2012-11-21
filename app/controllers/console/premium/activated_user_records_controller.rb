#encoding:utf-8
class Console::Premium::ActivatedUserRecordsController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_mobile_newspaper_console

  def index
    @mn_mobile_type = "history_index"
    @records = ActivatedUserRecord.includes(:staff).order("id desc").page(params[:page]).per(30)
  end

  def download
    @record = ActivatedUserRecord.find(params[:id])
    dir_str = "#{Rails.root}/bak_files/accounts_records/#{@record.created_at.strftime("%Y-%m-%d")}"
    file_path = "#{dir_str}/#{@record.file_name}"
    return render :text => "<script type='text/javascript'>alert('文件丢失');</script>" unless File.exists?(file_path)
    return send_file file_path, :filename => "每经网手机报有效用户-#{@record.created_at.strftime("%Y-%m-%d")}.txt"
  end
  
end
