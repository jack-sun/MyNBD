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
