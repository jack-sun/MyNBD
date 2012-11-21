module Sweepers
  class PageSweeper < ActionController::Caching::Sweeper

    observe ::Column

    def after_save(entry)
      column_id = []
      Column::COMBINED_COLUMNS.each do |k, v|
        column_id << v if k.include?(entry.id)
      end
      column_id << entry.id
      column_id.flatten.uniq.map do |c|
        expire_cache_object("column", c)
      end
    end

  end
end
