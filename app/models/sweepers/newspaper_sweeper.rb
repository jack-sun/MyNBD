module Sweepers
  class NewspaperSweeper < ActionController::Caching::Sweeper
    observe ::Newspaper


    def expire_newspaper_fragment(entry)
      Rails.cache.delete(entry.api_newspaper_cache_key)
      expire_cache_object(entry)
    end

    alias :after_save :expire_newspaper_fragment
    alias :after_destroy :expire_newspaper_fragment
  end
end
