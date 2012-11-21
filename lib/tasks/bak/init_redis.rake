namespace :redis do
  task :init => :environment do
    User.redis.keys.each do |key|
      User.redis.del(key)
    end
    User.all.each do |user|
      user.init_cache_data
    end
  end
end
