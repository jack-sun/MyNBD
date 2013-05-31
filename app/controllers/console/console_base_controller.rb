class Console::ConsoleBaseController < ApplicationController

  layout 'console'

  protected

  def work_logs(object, page, find_method)
    log_columns = generate_log_columns(object, find_method, page)
    # insert_null_into_log_columns(log_columns, find_method, page)
    insert_zero_to_month(log_columns) if find_method == 'month'

    sort_log_columns(log_columns, find_method)
    return log_columns
  end

  def init_work_log
    console = params[:console]
    news_console = console == 'news' && @current_staff.authority_of_news?
    common_console = console == 'common' && @current_staff.authority_of_common?
    return console, news_console, common_console
  end

  def work_log_total_page_old(object, find_method)
    per_page = Settings.work_log_per_page.to_i
    if object.class.to_s == 'Column'
      if find_method == 'day'
        total_page = ((Time.now.yesterday.to_date - columns_first_article(object).created_at.to_date).to_i) / per_page + 1
      else
        total_page = ((Time.now.yesterday.to_date - columns_first_article(object).created_at.to_date).to_i) / per_page + 1
      end
    elsif object.class.to_s == 'Staff'
      if find_method == 'day'
        total_page = object.articles.empty? ? 1 : ((Time.now.yesterday.to_date - object.articles.published.first.created_at.to_date).to_i) / per_page + 1
      else
        total_page = object.articles.empty? ? 1 : (Date.current.beginning_of_month - object.articles.published.first.created_at.to_date.beginning_of_month).to_i / (per_page * 30) + 1
      end
    end
    return total_page
  end

  def current_page(page, total_page)
    total_page = total_page.to_i
    page ||= 1
    page = page.to_i
    page = 1 if page < 1
    page = total_page if page > total_page
    return page
  end

  def console_convert_log_charge_staff(staff_convert_log)
    StaffConvertLog.find(staff_convert_log).charge_staff.try(:real_name) unless staff_convert_log.nil?
  end

  helper_method :console_convert_log_charge_staff

  private

  def columns_first_article(parent_column)
    ArticlesColumn.where(:column_id => Column.where(:parent_id => parent_column).select(:id)).first
  end

  def work_log_period(page, find_method)
    per_page = Settings.work_log_per_page.to_i
    if find_method == 'day'
      start_time = Time.now.end_of_day - (per_page * (page - 1)).day
      end_time = start_time - (per_page - 1).day
    elsif find_method == 'month'
      start_time = Date.current.end_of_month - (per_page * (page - 1)).month
      end_time = start_time - (per_page - 1).month
    end
    return start_time, end_time
  end

  def generate_log_columns(object, find_method, page)
    per_page = Settings.work_log_per_page.to_i
    offset = (page-1)*per_page
    if object.class.to_s == 'Staff' && find_method == 'day'
      log_columns = Article.find_by_sql(["select sum(articles.click_count) click_amount,
                                                   count(*) press_amount,
                                                   staff_convert_logs.id staff_convert_log_id,
                                                   staff_convert_logs.convert_count,
                                                   staff_convert_logs.status status,
                                                   date_format(articles.created_at,'%Y-%m-%d') log_date
                                            from articles, articles_staffs left join staff_convert_logs on 
                                            staff_convert_logs.date_at = date_format(articles_staffs.created_at,'%Y-%m-%d')
                                            and (staff_convert_logs.staff_id = articles_staffs.staff_id)
                                            where articles.status = 1
                                            and articles.id = articles_staffs.article_id
                                            and articles_staffs.staff_id = ?
                                            group by log_date order by articles.created_at DESC limit ? offset ?", object.id, per_page, offset])
    end

    if object.class.to_s == 'Staff' && find_method == 'month'
      log_columns = Article.find_by_sql(["select sum(articles.click_count) click_amount,
                                                   count(*) press_amount,
                                                   sum( distinct staff_convert_logs.convert_count) convert_count,
                                                   YEAR(articles.created_at) log_date_year,
                                                   MONTH(articles.created_at) log_date_month
                                            from articles, articles_staffs left join staff_convert_logs on 
                                            staff_convert_logs.date_at = date_format(articles_staffs.created_at,'%Y-%m-%d')
                                            and (staff_convert_logs.staff_id = articles_staffs.staff_id)
                                            where articles.status = 1
                                            and articles.id = articles_staffs.article_id
                                            and articles_staffs.staff_id = ?
                                            group by log_date_year, log_date_month order by articles.created_at DESC limit ? offset ?", object.id, per_page, offset])
    end

    if object.class.to_s == 'Column' && find_method == 'day'
      log_columns = Column.find_by_sql(["select sum(articles.click_count) click_amount,
                                                  count(*) press_amount,
                                                  date_format(articles.created_at,'%Y-%m-%d') log_date
                                           from articles, articles_columns
                                           where articles.status = 1
                                           and articles.id = articles_columns.article_id
                                           and articles_columns.column_id in (
                                             select id from columns where parent_id = ? and status = 1
                                           )
                                           group by log_date order by articles.created_at DESC limit ? offset ?", object.id, per_page, offset])
    end

    if object.class.to_s == 'Column' && find_method == 'month'
      log_columns = Column.find_by_sql(["select sum(articles.click_count) click_amount,
                                                  count(*) press_amount,
                                                  YEAR(articles.created_at) log_date_year,
                                                  MONTH(articles.created_at) log_date_month
                                           from articles, articles_columns
                                           where articles.status = 1
                                           and articles.id = articles_columns.article_id
                                           and articles_columns.column_id in (
                                             select id from columns where parent_id = ? and status = 1
                                           )
                                           group by log_date_year, log_date_month order by articles.created_at DESC limit ? offset ?", object.id, per_page, offset])
    end
    return log_columns
  end

  def generate_log_columns_old(object, find_method, page)
    start_time, end_time = work_log_period(page, find_method)
    if find_method == 'day'
      if object.class.to_s == 'Staff'
        log_columns = Article.find_by_sql(["select sum(articles.click_count) click_amount,
                                                   count(*) press_amount,
                                                   staff_convert_logs.id staff_convert_log_id,
                                                   staff_convert_logs.convert_count,
                                                   staff_convert_logs.status status,
                                                   date_format(articles.created_at,'%Y-%m-%d') log_date
                                            from articles, articles_staffs left join staff_convert_logs on 
                                            staff_convert_logs.date_at = date_format(articles_staffs.created_at,'%Y-%m-%d')
                                            and (staff_convert_logs.staff_id = articles_staffs.staff_id)
                                            where articles.status = 1
                                            and articles.id = articles_staffs.article_id
                                            and articles_staffs.staff_id = ?
                                            and articles.created_at between ? and ?
                                            group by log_date", object.id, end_time, start_time])
      elsif object.class.to_s == 'Column'
        log_columns = Column.find_by_sql(["select sum(articles.click_count) click_amount,
                                                  count(*) press_amount,
                                                  date_format(articles.created_at,'%Y-%m-%d') log_date
                                           from articles, articles_columns
                                           where articles.status = 1
                                           and articles.id = articles_columns.article_id
                                           and articles.created_at between ? and ?
                                           and articles_columns.column_id in (
                                             select id from columns where parent_id = ? and status = 1
                                           )
                                           group by log_date", end_time, start_time, object.id])
      end
    elsif find_method == 'month'
      if object.class.to_s == 'Staff'
        log_columns = Article.find_by_sql(["select sum(articles.click_count) click_amount,
                                                   count(*) press_amount,
                                                   sum( distinct staff_convert_logs.convert_count) convert_count,
                                                   YEAR(articles.created_at) log_date_year,
                                                   MONTH(articles.created_at) log_date_month
                                            from articles, articles_staffs left join staff_convert_logs on 
                                            staff_convert_logs.date_at = date_format(articles_staffs.created_at,'%Y-%m-%d')
                                            and (staff_convert_logs.staff_id = articles_staffs.staff_id)
                                            where articles.status = 1
                                            and articles.id = articles_staffs.article_id
                                            and articles_staffs.staff_id = ?
                                            and articles.created_at between ? and ?
                                            group by log_date_year, log_date_month", object.id, end_time, start_time])
      elsif object.class.to_s == 'Column'
        log_columns = Column.find_by_sql(["select sum(articles.click_count) click_amount,
                                                  count(*) press_amount,
                                                  YEAR(articles.created_at) log_date_year,
                                                  MONTH(articles.created_at) log_date_month
                                           from articles, articles_columns
                                           where articles.status = 1
                                           and articles.id = articles_columns.article_id
                                           and articles.created_at between ? and ?
                                           and articles_columns.column_id in (
                                             select id from columns where parent_id = ? and status = 1
                                           )
                                           group by log_date_year, log_date_month", end_time, start_time, object.id])
      end
    end
    return log_columns
  end

  def sort_log_columns(log_columns, find_method)
    if find_method == 'day'
      log_columns.sort! { |x,y| y[:log_date] <=> x[:log_date] }
    elsif find_method == 'month'
      log_columns.sort! do |x,y|
        "#{y[:log_date_year]}-#{y[:log_date_month]}" <=> "#{x[:log_date_year]}-#{x[:log_date_month]}"
      end
    end
  end

  def insert_null_into_log_columns(log_columns, find_method, page)
    start_time, end_time = work_log_period(page, find_method)
    if find_method == 'day'
      log_dates = log_columns.map(&:log_date)
      for date in end_time.to_date..start_time.to_date
        unless log_dates.include?(date.to_s)
          log_column = {:press_amount => 0, :click_amount => 0, :log_date => date.to_s}
          log_columns << log_column
        end
      end
    elsif find_method == 'month'
      log_dates = log_columns.map { |log| "#{log.log_date_year}-#{log.log_date_month}" }
      for date in end_time.to_date..start_time.to_date
        next if date.day != 1
        unless log_dates.include?("#{date.year}-#{date.month}")
          log_column = {:press_amount => 0, :click_amount => 0, :log_date_year => date.year, :log_date_month => date.month}
          log_columns << log_column
        end
      end
    end
  end

  def insert_zero_to_month(log_columns)
    for log_column in log_columns
      log_column[:log_date_month] = "0#{log_column[:log_date_month]}" if log_column[:log_date_month] < 10
    end
  end

  def work_log_total_page(object, find_method)
    if object.class.to_s == 'Staff' && find_method == 'day'
      total_records_count = Article.find_by_sql(["select count(*) total_count from 
                                              (select date_format(articles.created_at,'%Y-%m-%d') log_date
                                                from articles, articles_staffs left join staff_convert_logs on 
                                                staff_convert_logs.date_at = date_format(articles_staffs.created_at,'%Y-%m-%d')
                                                and (staff_convert_logs.staff_id = articles_staffs.staff_id)
                                                where articles.status = 1
                                                and articles.id = articles_staffs.article_id
                                                and articles_staffs.staff_id = ?
                                                group by log_date) sub_table", object.id])
    end

    if object.class.to_s == 'Staff' && find_method == 'month'
      total_records_count = Article.find_by_sql(["select count(*) total_count from (
                                                    select YEAR(articles.created_at) log_date_year,
                                                      MONTH(articles.created_at) log_date_month
                                                      from articles, articles_staffs left join staff_convert_logs on 
                                                      staff_convert_logs.date_at = date_format(articles_staffs.created_at,'%Y-%m-%d')
                                                      and (staff_convert_logs.staff_id = articles_staffs.staff_id)
                                                      where articles.status = 1
                                                      and articles.id = articles_staffs.article_id
                                                      and articles_staffs.staff_id = ?
                                                      group by log_date_year, log_date_month) sub_table", object.id])
    end

    if object.class.to_s == 'Column' && find_method == 'day'
      total_records_count = Column.find_by_sql(["select count(*) total_count from 
                                                  (select date_format(articles.created_at,'%Y-%m-%d') log_date
                                                     from articles, articles_columns
                                                     where articles.status = 1
                                                     and articles.id = articles_columns.article_id
                                                     and articles_columns.column_id in (
                                                       select id from columns where parent_id = ? and status = 1
                                                     )
                                                     group by log_date) sub_table", object.id])
    end

    if object.class.to_s == 'Column' && find_method == 'month'
      total_records_count = Column.find_by_sql(["select count(*) total_count from (select 
                                                  YEAR(articles.created_at) log_date_year,
                                                  MONTH(articles.created_at) log_date_month
                                           from articles, articles_columns
                                           where articles.status = 1
                                           and articles.id = articles_columns.article_id
                                           and articles_columns.column_id in (
                                             select id from columns where parent_id = ? and status = 1
                                           )
                                           group by log_date_year, log_date_month) sub_table", object.id])
    end
    per_page = Settings.work_log_per_page.to_i
    total_records_count = total_records_count.first.total_count
    total_page = total_records_count/per_page
    return total_records_count%per_page == 0 ? total_page : total_page+1
  end

end
