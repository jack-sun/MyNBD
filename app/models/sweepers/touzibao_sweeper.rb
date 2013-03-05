module Sweepers
  class TouzibaoSweeper < ActionController::Caching::Sweeper
    observe ::Touzibao

    def expire_touzibao_fragment(entry)
      expire_cache_object("touzibao", 'today') unless entry.nil?
      expire_cache_object("touzibao", 'latest') unless entry.nil?
	  expire_cache_object(entry) unless entry.nil?
    end

    alias :after_save :expire_touzibao_fragment
    alias :after_destroy :expire_touzibao_fragment
  end
end
