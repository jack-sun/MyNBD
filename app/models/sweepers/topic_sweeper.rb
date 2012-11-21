module Sweepers
  class TopicSweeper < ActionController::Caching::Sweeper
    observe ::Topic

    def expire_cached_content(entry)
      expire_fragment(::Topic::HOT_TOPIC_FRAGMENT_CACHE_KEY)
    end

    alias :after_save :expire_cached_content
    alias :after_destroy :expire_cached_content
  end
end
