#encoding:utf-8
module Nbd
  module CacheFilter
    def find_by_rails_cache_or_db(cache_key, options = {})
      object = Rails.cache.read cache_key
      unless object
        object = yield
        Rails.cache.write cache_key, object.to_s, options
      end
      
      return object
    end

    def find_by_your_cache_or_db(cache_client, cache_key, options = {})
      object = cache_client.get cache_key
      unless object
        object = yield
        cache_client.set cache_key, object.to_s, options
      end
      return object
    end
  end
end
