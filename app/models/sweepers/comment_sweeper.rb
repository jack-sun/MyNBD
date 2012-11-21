module Sweepers
  class CommentSweeper < ActionController::Caching::Sweeper
    observe ::Comment

    def expire_article_fragment(entry)
      expire_cache_object("article", entry.article_id) unless entry.article_id.nil?
    end

    alias :after_save :expire_article_fragment
    alias :after_destroy :expire_article_fragment
  end
end
