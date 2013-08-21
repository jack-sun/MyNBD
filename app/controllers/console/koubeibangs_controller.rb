#encoding:utf-8
require "spreadsheet"
require 'fileutils'
class Console::KoubeibangsController < ApplicationController
  layout "console"
  skip_before_filter :current_user
  before_filter :current_staff
  before_filter :authorize_staff
  before_filter :init_community_console

  def index
    @koubeibang_navs = "review_comment"
    @koubeibang_comment_navs = params[:status] || "all"
    if @koubeibang_comment_navs == "all"
      @koubeibang_details = KoubeibangCandidateDetail.order('id DESC').page(params[:page]).per(20)
    else
      @koubeibang_details = KoubeibangCandidateDetail.where(:comment_status => KoubeibangCandidateDetail::BANNDED).order('id DESC').page(params[:page]).per(20)
    end
  end

  # AJAX： 更改文章状态
  def change_status
    @koubeibang_detail = KoubeibangCandidateDetail.find(params[:id])
    
    unless @koubeibang_detail.update_attributes(:comment_status => params[:status])
      return render :js => "alert('更改失败')"
    end
    @objects = [@koubeibang_detail]
  end  

  def export_to_xls
    book = Spreadsheet::Workbook.new
    koubeibangs = Koubeibang.all
    file_name = "#{Rails.root}/tmp/口碑榜提名.xls"

    koubeibangs.each do |koubeibang|
      candidates = koubeibang.koubeibang_candidates.order('id desc')
      sheet = book.create_worksheet(:name => koubeibang.title)
      sheet.row(0).concat ["股票代码", "公司名称", "提名理由"]
      row_index = 1
      candidates.each do |candidate|
        details = candidate.koubeibang_candidate_details.order('id desc')
        details.each_with_index do |detail, index|
          sheet.row(row_index).concat [candidate.stock_code, candidate.stock_company, detail.comment]
          row_index += 1
        end
      end
    end
    book.write file_name
    return send_file file_name
  end
  
end
