module Sweepers
  class ColumnistSweeper < ActionController::Caching::Sweeper

    observe ::Columnist

    def after_save(entry)
      if entry.last_article_id_changed?
        expire_cache_object("columnist", "index_table")
      end
      expire_cache_object(entry)
    end

    def after_destroy(entry)
      expire_cache_object("columnist", "index_table")
      expire_cache_object(entry)
    end

  end
end
