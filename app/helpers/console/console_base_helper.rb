#encoding: utf-8
module Console::ConsoleBaseHelper
  def work_log_paginate(object)
    content = ''

    if @page != 1
      if object == 'column'
        content << (content_tag :span, link_to('首页', console_column_work_log_url(params[:id], :console => @console, :find_method => @find_method, :page => 1)) if @page.present?)
        content << (content_tag :span, link_to('&laquo; 上一页'.html_safe, console_column_work_log_url(params[:id], :console => @console, :find_method => @find_method, :page => @page.to_i - 1)))
      elsif object == 'staff'
        content << (content_tag :span, link_to('首页', console_staff_work_log_path(@staff, :console => @console, :find_method => @find_method, :page => 1)) if @page != 1)
        content << (content_tag :span, link_to('&laquo; 上一页'.html_safe, console_staff_work_log_path(@staff, :console => @console, :find_method => @find_method, :page => @page - 1)) if @page != 1)
      end
    end

    if @page < 5
      max_page = @total_page < 5 ? @total_page : 5
      for page in 1..max_page
        if object == 'column'
          content << (content_tag :span, link_to_unless(page == @page, page.to_s, console_column_work_log_url(params[:id], :console => @console, :find_method => @find_method, :page => page)), :class => "page #{'current' if page == @page}")
        elsif object == 'staff'
          content << (content_tag :span, link_to_unless(page == @page, page.to_s, console_staff_work_log_url(@staff, :console => @console, :find_method => @find_method, :page => page)), :class => "page #{'current' if page == @page}")
        end  
      end
    else
      content << "<span><a href='javascript:void(0)'>...</a></span>" if @page - 4 > 1
      max_page = @total_page < @page + 4 ? @total_page : @page + 4
      for page in (@page - 4)..max_page
        if object == 'column'
          content << (content_tag :span, link_to_unless(page == @page, page.to_s, console_column_work_log_url(params[:id], :console => @console, :find_method => @find_method, :page => page)), :class => "page #{'current' if page == @page}")
        elsif object == 'staff'
          content << (content_tag :span, link_to_unless(page == @page, page.to_s, console_staff_work_log_url(@staff, :console => @console, :find_method => @find_method, :page => page)), :class => "page #{'current' if page == @page}")
        end
      end
      content << "<span><a href='javascript:void(0)'>...</a></span>" if @total_page > @page + 4
    end

    if @page.to_i != @total_page
      if object == 'column'
        content << (content_tag :span, link_to('下一页 &raquo;'.html_safe,console_column_work_log_url(params[:id], :console => @console, :find_method => @find_method, :page => @page.to_i + 1)))
        content << (content_tag :span, link_to('末页',console_column_work_log_url(params[:id], :console => @console, :find_method => @find_method, :page => @total_page)))
      elsif object == 'staff'
        content << (content_tag :span, link_to('下一页 &raquo;'.html_safe, console_staff_work_log_path(@staff, :console => @console, :find_method => @find_method, :page => @page + 1)) if @page != @total_page)
        content << (content_tag :span, link_to('末页', console_staff_work_log_path(@staff, :console => @console, :find_method => @find_method, :page => @total_page)) if @page != @total_page)
      end
    end

    return content.html_safe
  end

  def average_hits(work_log)
    work_log[:click_amount] == 0 ? 0 : sprintf("%.1f", work_log.click_count / work_log.post_count)
  end


  def insert_zero_to_month(date_index)
    year = date_index.split("-").first
    month = date_index.split("-").last
    date_index = "#{year}-0#{month}" if month.to_i < 10
    return date_index
  end

  def log_date(performance_log)
    @find_method == 'day' ? performance_log.date_at : insert_zero_to_month(performance_log.date_index)
  end

  def performance_log_find_by_month?
    params[:date].split("-").size == 2
  end
end
