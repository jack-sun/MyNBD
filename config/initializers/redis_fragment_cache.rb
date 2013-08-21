require "redis_fragment_cache"
require 'redis'
require 'redis-store'
RedisFragmentCache.configure do |config|
  config.redis_client = Redis.new(Redis::Factory.convert_to_redis_client_options(Settings.redis_page_cache_store))
  config.yml_file_path = "#{Rails.root}/config/page_cache_key.yml"
  config.expire_time = 60*60*24
  config.suffix = "\#{request.subdomain}_\#{params[:controller]}_\#{params[:action]}_\#{params[:id]}_\#{params[:page]}"
end
RedisFragmentCache.register!

module RedisFragmentCache
  module InitFragmentKeyMethods
    module InstanceMethods
      def expire_cache_object(*args)
        t = Time.now
        if args.count > 1
          set_key = send("#{args[0]}_set_key", args[1])
        else
          set_key = send("#{args[0].class.to_s.downcase}_set_key", args[0].id)
        end
        keys_array = RedisFragmentCache.configuration.redis_client.smembers set_key
        RedisFragmentCache.configuration.redis_client.del *keys_array if keys_array and keys_array.count > 0
        
        mirror_keys_array = Nbd::Application.mirror_redis_client.smembers set_key
        Nbd::Application.mirror_redis_client.del *mirror_keys_array  if mirror_keys_array and mirror_keys_array.count > 0
        
        RedisFragmentCache.configuration.redis_client.del set_key
        Nbd::Application.mirror_redis_client.del set_key
        
        Rails.logger.debug "expire fragments key #{set_key}, count: #{keys_array.count}, cost #{Time.now - t} seconds"
      end

      def nbd_expire_fragment_key(key)
        t = Time.now
        success = RedisFragmentCache.configuration.redis_client.del key
        Nbd::Application.mirror_redis_client.del key
        Rails.logger.debug "expire fragments key #{key}, success:#{success}, cost #{Time.now - t} seconds"
      end
    end
  end
end