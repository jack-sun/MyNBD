require 'active_support/log_subscriber'
require 'redis'
require 'redis/objects'
require 'redis-store'
#class CacheCallback::BaseCallback
  ##
  #START_TIME = Time.new("2011-10-01")
  ##the fragment' length, now is 24 hours
  #FRAGMENT_LENGTH = 60 * 24
  #LIST_LENGTH = (7.days)/(FRAGMENT_LENGTH.minutes)
  #VALID_TYPE = ["weibo", "article", "user", "tag"]
  #RESULT_MAX_LENTH = 100
  #HOT_COMMENT_ARTICLE_KEY = "hot_cache:result:hot_comment_article"
  #HOT_ARTICLE_KEY = "hot_cache:result:hot_article"
  #HOT_RT_WEIBO_KEY = "hot_cache:result:hot_rt_weibo"
  #HOT_TAG_KEY = "hot_cache:result:hot_tag"
  #ACTIVE_USER_KEY = "hot_cache:result:active_user"
  #LOGGER = Logger.new(File.expand_path("../../../log/resque-scheduler.log", File.dirname(__FILE__)))
  #LOGGER.level = Logger::DEBUG

  #INTERVL_COUNT = 10000
  #INTERVL_TIME = 10

  #TAG_WEIGHT_HASH = {"ori_weibo_count" => 10, "comment_count" => 8, "rt_weibo_count" => 5, "ori_comment_weibo_count" => 3}
  #USER_WEIGHT_HASH = {"weibo_count" => 10, "comment_count" => 8, "rt_count" => 5, "followings_count" => 0.5}

  #$callback_redis = Redis.new(Redis::Factory.convert_to_redis_client_options(Settings.redis_cache_store))
  #PREFIX_LIST_KEY = "hot_cache:key_prefix_list"

  #def self.redis_client
    #$callback_redis
  #end

  #def self.current_key_prefix
    #$callback_redis.lindex PREFIX_LIST_KEY, 0
  #end

  #def self.global_object_key(object)
    #if object.size == 1
      #object = object.first
      #object.is_a?(String) ? "hot_cache:tag:#{object}:cache" : "hot_cache:#{object.class.to_s.downcase}:#{object.id}:cache"
    #elsif object.size == 2
      #"hot_cache:#{object.first.downcase}:#{object.last}:cache"
    #end
  #end

  #def self.fragment_object_key(object)
    #if object.size == 1
      #object = object.first
      #object.is_a?(String) ? "#{current_key_prefix}:tag:#{object}:cache" : "#{current_key_prefix}:#{object.class.to_s.downcase}:#{object.id}:cache"
    #elsif object.size == 2
      #"#{current_key_prefix}:#{object.first.downcase}:#{object.last}:cache"
    #end
  #end

  #def self.increment_count(count_name, *object)
    #$callback_redis.hincrby global_object_key(object), count_name, 1
    #$callback_redis.hincrby fragment_object_key(object), count_name, 1
  #end

  #def self.decrement_count(count_name, *object)
    #$callback_redis.hincrby global_object_key(object), count_name, -1
    #$callback_redis.hincrby fragment_object_key(object), count_name, -1
  #end

  #def self.should_delete_oldest_count
    #($callback_redis.llen PREFIX_LIST_KEY).to_i > LIST_LENGTH
  #end

  #def self.perform
    #LOGGER.debug "------------start------------------------"
    #current_last_prefix_key = current_key_prefix
    #LOGGER.debug "------------  current_last_prefix_key    #{current_last_prefix_key}------------------------"
    #push_new_frag_id
    #decrement_old_count(*VALID_TYPE) if should_delete_oldest_count
    
    
    #get_hot_rt_weibo(current_last_prefix_key)
    #get_hot_article(current_last_prefix_key)
    #get_hot_tag(current_last_prefix_key)
    #get_active_user(current_last_prefix_key)
    #LOGGER.debug "---------------- finish -----------------"
  #end

  #class << self
    #def frag_id
      #(Time.now - START_TIME).to_i/60/FRAGMENT_LENGTH
    #end

    #def push_new_frag_id
      #LOGGER.debug "------- push new frag #{frag_id} id to list ----------"
      #c= $callback_redis.lpush PREFIX_LIST_KEY, "hot_cache:#{frag_id}"
    #end

    #def the_oldest_prefix_key
      #$callback_redis.rpop PREFIX_LIST_KEY
    #end

    #def decrement_old_count(*types)
      #deprecate_keys = the_oldest_prefix_key
      #types.each do |type|
        #next if (!type.is_a? String) || (!VALID_TYPE.include? type)
        #old_keys = $callback_redis.keys "#{deprecate_keys}:#{type}:*:cache"
        #LOGGER.debug "------------------- start delete deprecate #{type} count --------------------"
        #old_keys.tap do |t|
          #LOGGER.debug "------------------- #{t.size} deprecated #{type} --------------------"
        #end.each do |key|
          #object_id = key.split(":")[3]
          #LOGGER.debug "-------------------  decrement #{type} #{object_id} count--------------------"
          #new_array = []
          #old_hash = $callback_redis.hgetall key
          #global_key = "hot_cache:#{type}:#{object_id}:cache"
          #global_hash = $callback_redis.hgetall global_key
          #global_hash.each do |k, v|
            #next if k == "create_time"
            #new_array << k
            #new_array << (global_hash[k].to_i - (old_hash[k]||0).to_i)
          #end
          #LOGGER.debug "--------- result: #{new_array}"
          #$callback_redis.hmset global_key, *new_array unless new_array.blank?
          #$callback_redis.del key
        #end
      #end
    #rescue Exception => e
      #LOGGER.debug "ERROR : #{e.inspect}"
    #end

    #def get_object_point(object_key, lates_key_prefix, *count_name)
      #global_values = $callback_redis.hgetall object_key
      #last_fragment_values = $callback_redis.hgetall "#{lates_key_prefix}#{object_key[9..-1]}"
      #create_time = global_values["create_time"]
      #unless create_time
        #c = get_create_time_by_key(object_key)
        #if c
          #create_time = c
          #$callback_redis.hset object_key, "create_time", c
        #else
          #$callback_redis.del object_key
          #object[10,0] = "*:" # for delete 'hot_cache:*:article:111111:cache'
          #$callback_redis.del object_key
          #return nil
        #end
      #end
      #count_name.map! do |name|
        #c = hacker_news_point((global_values[name]||0).to_i + (last_fragment_values[name]||0).to_i, create_time)
        #LOGGER.debug "----------- #{object_key} #{c} -------------"
        #c
      #end
      #LOGGER.debug "##########{count_name}"
      #return count_name
    #end

    #def hacker_news_point(point, create_time)
      #point.to_f/(((Time.now-Time.parse(create_time)).hour)**(1.8))
    #end

    #def get_object_point_2(object_key, lates_key_prefix, weight_hash)
      #global_count = $callback_redis.hgetall object_key
      #last_fragment_count = $callback_redis.hgetall "#{lates_key_prefix}#{object_key[9..-1]}"
      #global_value = get_point_by_hash(global_count, weight_hash)
      #last_fragment_value = get_point_by_hash(last_fragment_count, TAG_WEIGHT_HASH)
      #global_value * 0.2 + last_fragment_value * 0.8
    #end

    #def get_point_by_hash(tag_hash, weight_hash)
      #point = 0
      #weight_hash.each do |k, v|
        #point += (tag_hash[k]||0).to_i * v
      #end
      #return point
    #end

    #def get_create_time_by_key(object_key)
      #object_type, object_id = object_key.split(":")[1..2]
      #object = object_type.camelize.constantize.where(:id => object_id).first
      #object ? object.created_at.to_s(:db) : nil
    #end

    #def get_hot_rt_weibo(lates_key_prefix)
      #LOGGER.debug "---------------- start get hot rt weibo ----------------"
      #all_weibo_keys = $callback_redis.keys "hot_cache:weibo:*:cache"
      #init_count = 0
      #all_weibo_keys.each do |key|
        #object_id = key.split(":")[2]
        #rt_point, = get_object_point(key, lates_key_prefix, "rt_count")
        #push_to_result_and_sort(HOT_RT_WEIBO_KEY, object_id, rt_point) if rt_point && rt_point > 0
        #if init_count == INTERVL_COUNT
          #init_count = 0
          #sleep(INTERVL_TIME)
        #else
          #init_count += 1
        #end
      #end
    #rescue Exception => e
      #LOGGER.debug "ERROR : #{e.inspect}"
    #end

    #def get_hot_article(lates_key_prefix)
      #LOGGER.debug "-------------------- start get hot article ---------------------"
      #clear_hot_record(HOT_ARTICLE_KEY)
      #clear_hot_record(HOT_COMMENT_ARTICLE_KEY)
      #deprecated_article_ids = excipted_article_ids
      #all_article_keys = $callback_redis.keys "hot_cache:article:*:cache"
      #init_count = 0
      #all_article_keys.each do |key|
        #object_id = key.split(":")[2]
        #next if deprecated_article_ids.include?(object_id.to_i)
        #click_point, comment_point = get_object_point(key, lates_key_prefix, "click_count", "comment_count")
        #if click_point
          #push_to_result_and_sort(HOT_ARTICLE_KEY, object_id, click_point) if click_point > 0
          #push_to_result_and_sort(HOT_COMMENT_ARTICLE_KEY, object_id, comment_point) if comment_point > 0
        #end
        #if init_count == INTERVL_COUNT
          #init_count = 0
          #sleep(INTERVL_TIME)
        #else
          #init_count += 1
        #end
      #end
    #rescue Exception => e
      #LOGGER.debug "ERROR : #{e.inspect}"
    #end

    #def get_hot_tag(lates_key_prefix)
      #LOGGER.debug "------------------  start get hot tag ---------------------"
      #all_article_keys = $callback_redis.keys "hot_cache:tag:*:cache"
      #init_count = 0
      #all_article_keys.each do |key|
        #object_id = key.split(":")[2]
        #tag_point = get_object_point_2(key, lates_key_prefix,TAG_WEIGHT_HASH)
        #push_to_result_and_sort(HOT_TAG_KEY, object_id, tag_point)
        #if init_count == INTERVL_COUNT
          #init_count = 0
          #sleep(INTERVL_TIME)
        #else
          #init_count += 1
        #end
      #end
    #rescue Exception => e
      #LOGGER.debug "ERROR : #{e.inspect}"
    #end

    #def get_active_user(lates_key_prefix)
      #LOGGER.debug "----------------- start get active user -------------------"
      #all_article_keys = $callback_redis.keys "hot_cache:user:*:cache"
      #init_count = 0
      #all_article_keys.each do |key|
        #object_id = key.split(":")[2]
        #user_point = get_object_point_2(key, lates_key_prefix, USER_WEIGHT_HASH)
        #push_to_result_and_sort(ACTIVE_USER_KEY, object_id, user_point)
        #if init_count == INTERVL_COUNT
          #init_count = 0
          #sleep(INTERVL_TIME)
        #else
          #init_count += 1
        #end
      #end
    #rescue Exception => e
      #LOGGER.debug "ERROR : #{e.inspect}"
    #end

    #def push_to_result_and_sort(key, member, point)
      #LOGGER.debug "------ #{member}  #{point}  -------"
      #$callback_redis.zadd key, point, member
      #length = $callback_redis.zcard key
      #$callback_redis.zremrangebyrank key, 0, 0 if length.to_i > RESULT_MAX_LENTH
    #end


    #def excipted_article_ids
      #ArticlesColumn.where(:column_id => Column::EXCEPT_IDS).map(&:article_id).compact.uniq!
    #end

    #def clear_hot_record(key)
      #$callback_redis.zremrangebyrank key, 0, -1
    #end
  #end
#end

class CacheCallback::BaseCallback
  LOGGER = Logger.new(File.expand_path("../../../log/resque-scheduler.log", File.dirname(__FILE__)))
  LOGGER.level = Logger::DEBUG

  GLOBAL_KEY_EXPIRE_TIME = 7.days
  HOT_KEY_EXPIRE_TIME = 1.days
  INTERVL_COUNT = 1000
  INTERVL_TIME = 10

  HOT_COMMENT_ARTICLE_KEY = "hot_cache:result:hot_comment_article"
  HOT_ARTICLE_KEY = "hot_cache:result:hot_article"
  HOT_COLUMN_ARTICLE_KEY = "hot_cache:result:hot_column_article"
  HOT_RT_WEIBO_KEY = "hot_cache:result:hot_rt_weibo"
  HOT_TAG_KEY = "hot_cache:result:hot_tag"
  ACTIVE_USER_KEY = "hot_cache:result:active_user"
  HOT_GALLERY_KEY = "hot_cache:result:hot_gallery"
  RESULT_MAX_LENTH = 100

  HOT_KEY_MAP = { "weibo" => [HOT_RT_WEIBO_KEY], "article" => [HOT_COMMENT_ARTICLE_KEY, HOT_ARTICLE_KEY], 
                  "user" => [ACTIVE_USER_KEY], "tag" => [HOT_TAG_KEY], "column" => [HOT_COLUMN_ARTICLE_KEY], 
                  "gallery" => [HOT_GALLERY_KEY] }
  
  TAG_WEIGHT_HASH = {"ori_weibo_count" => 10, "comment_count" => 8, "rt_weibo_count" => 5, "ori_comment_weibo_count" => 3}
  USER_WEIGHT_HASH = {"weibo_count" => 10, "comment_count" => 8, "rt_count" => 5, "followings_count" => 0.5}

  class << self

    def redis_client
      @@redis_client ||= Redis.new(Redis::Factory.convert_to_redis_client_options(Settings.redis_cache_store))
    end

    # method for resque scheduler
    def perform
      add_up_active_user
      add_up_hot_tag
      add_up_hot_rt_weibo
      add_up_hot_article
      add_up_hot_column_article
      add_up_hot_gallery
    end

    # two importain methdos fo subclasses
    def increment_count(count_name, *object)
      t = Time.now
      global_key = global_object_key(object)
      redis_client.hincrby global_key, count_name, 1
      redis_client.expire global_key, GLOBAL_KEY_EXPIRE_TIME

      hot_key = fragment_object_key(object)
      redis_client.hincrby hot_key, count_name, 1
      redis_client.expire hot_key, HOT_KEY_EXPIRE_TIME
      LOGGER.debug "############# cache callback cost time : #{Time.now - t}"
    end

    def decrement_count(count_name, *object)
      redis_client.hincrby global_object_key(object), count_name, -1
      redis_client.hincrby fragment_object_key(object), count_name, -1
    end

    def tag_detail(tag)
      redis_client.hgetall global_object_key(Array.wrap(tag))
    end

    private

    # add up data methdos:
    # article
    # weibo
    # weibo tag
    # active user
    # gallery
    #

    def add_up_hot_article
      add_up_object_data("article") do |key|
        click_point, comment_point = nice_object_point(key, "click_count", "comment_count")
        if click_point
          object_id = key.split(":")[3]
          push_to_result_and_sort(HOT_ARTICLE_KEY, object_id, click_point) if click_point > 0
          push_to_result_and_sort(HOT_COMMENT_ARTICLE_KEY, object_id, comment_point) if comment_point > 0
        end
      end
      Resque.enqueue(Jobs::UpdateStaticFragmentPage, nil, {:hot_articles => []})
    end

    def add_up_hot_rt_weibo
      add_up_object_data("weibo") do |key|
        rt_point, = nice_object_point(key, "rt_count")
        if rt_point
          object_id = key.split(":")[3]
          push_to_result_and_sort(HOT_RT_WEIBO_KEY, object_id, rt_point) if rt_point > 0
        end
      end
    end

    def add_up_hot_tag
      add_up_object_data("tag") do |key|
        tag_point = simple_object_point(key, TAG_WEIGHT_HASH)
        if tag_point
          object_id = key.split(":")[3]
          push_to_result_and_sort(HOT_TAG_KEY, object_id, tag_point) if tag_point > 0
        end
      end
    end

    def add_up_active_user
      add_up_object_data("user") do |key|
        user_point = simple_object_point(key, USER_WEIGHT_HASH)
        if user_point
          object_id = key.split(":")[3]
          push_to_result_and_sort(ACTIVE_USER_KEY, object_id, user_point) if user_point > 0
        end
      end
    end

    def add_up_hot_column_article
      hot_columns = Column::COLUMN_MORE.keys + [185] - [56, 145, 175, 197]
      flag_columns = hot_columns.dup
      add_up_object_data("column") do |key|
        click_point, comment_point = nice_object_point(key, "click_count", "comment_count")
        if click_point
          object_id = key.split(":")[3]
          temp_article = Article.where(:id => object_id).first
          temp_article_columns = []
          temp_article.columns.each do |column|
            if column.parent_id.present?
              temp_article_columns << column.parent_id
            else
              temp_article_columns << column.id
            end
          end
          if (record_columns = hot_columns & temp_article_columns).present?
            record_columns.each do |record_column|
              if flag_columns.include? record_column
                clear_result_list("#{HOT_COLUMN_ARTICLE_KEY}:#{record_column}")
                flag_columns = flag_columns - [record_column]
              end
              push_to_result_and_sort("#{HOT_COLUMN_ARTICLE_KEY}:#{record_column}", object_id, click_point) if click_point > 0
            end
          end
        end
      end
      hot_columns.each do |hot_column|
        redis_client.del "#{HOT_COLUMN_ARTICLE_KEY}:#{hot_column}_tmp"
      end
    rescue Exception => e
      LOGGER.debug "------ error :#{e} -------"
      LOGGER.debug "------ backtrace :#{e.backtrace} -------"
      hot_columns.each do |hot_column|
        reverse_from_tmp_list("#{HOT_COLUMN_ARTICLE_KEY}:#{hot_column}_tmp")
      end
    end

    def add_up_hot_gallery
      add_up_object_data("gallery") do |key|
        click_point, = nice_object_point(key, "click_count")
        LOGGER.debug "------ ########################################Gallery -------"
        LOGGER.debug "------ click_count :#{click_point} -------"
        if click_point
          object_id = key.split(":")[3]
          LOGGER.debug "------ click_count :#{object_id} -------"
          push_to_result_and_sort(HOT_GALLERY_KEY, object_id, click_point) if click_point > 0
        end
      end
    end

    # basic add up method

    def add_up_object_data(type)
      init_count = 0

      LOGGER.debug "------ start add up #{type} data -------"
      HOT_KEY_MAP[type].each do |key|
        clear_result_list(key)
      end unless type == "column"
      redis_client.smembers(objects_set_key(type == "column" ? "article" : type)).each do |key|
        if init_count == INTERVL_COUNT
          init_count = 0
          sleep(INTERVL_TIME)
        else
          init_count += 1
        end
        if redis_client.type(key) != "none"
          yield key
        else
          redis_client.srem objects_set_key(type == "column" ? "article" : type), key
        end
      end
      LOGGER.debug "------ end add up #{type} data -------"
      HOT_KEY_MAP[type].each do |key|
        redis_client.del "#{key}_tmp"
      end unless type == "column"
    rescue Exception => e
      LOGGER.debug "------ error :#{e} -------"
      LOGGER.debug "------ backtrace :#{e.backtrace} -------"
      HOT_KEY_MAP[type].each do |key|
        reverse_from_tmp_list(key)
      end unless type == "column"
    end


    # key methods

    def objects_set_key(object)
      if object.is_a? String
        "hot_cache:set_key:#{object.downcase}"
      else
        "hot_cache:set_key:#{object.class.to_s.downcase}"
      end
    end

    def global_object_key(object, update_set = true)
      key = ""
      if object.size == 1
        object = object.first
        key = object.is_a?(String) ? "hot_cache:object_global_key:tag:#{object}:cache" : "hot_cache:object_global_key:#{object.class.to_s.downcase}:#{object.id}:cache"
        if update_set
          set_key = object.is_a?(String) ? objects_set_key("tag") : objects_set_key(object)
          redis_client.sadd set_key, key
        end
      elsif object.size == 2
        key = "hot_cache:object_global_key:#{object.first.downcase}:#{object.last}:cache"
        if update_set
          set_key = objects_set_key(object.first)
          redis_client.sadd set_key, key
        end
      end
      return key
    end

    def fragment_object_key(object)
      if object.size == 1
        object = object.first
        key = object.is_a?(String) ? "hot_cache:object_hot_key:tag:#{object}:cache" : "hot_cache:object_hot_key:#{object.class.to_s.downcase}:#{object.id}:cache"
      elsif object.size == 2
        key = "hot_cache:object_hot_key:#{object.first.downcase}:#{object.last}:cache"
      end
      return key
    end


    # two important point methods

    def simple_object_point(key, weight_hash)
      global_count = redis_client.hgetall key
      hot_count = redis_client.hgetall convert_global_to_hot_key(key)
      point_by_hash(global_count, weight_hash) * 0.2 + point_by_hash(hot_count, weight_hash) * 0.8
    end

    def nice_object_point(object_key, *counter_names)
      global_count = redis_client.hgetall object_key
      hot_count = redis_client.hgetall convert_global_to_hot_key(object_key)
      created_time = global_count["create_time"]
      unless created_time
        c = created_time_of_key(object_key)
        if c
          created_time = c
          redis_client.hset object_key, "create_time", c
        else
          redis_client.del object_key
        end
      end

      counter_names.map! do |name|
        c = hacker_news_point((global_count[name]||0).to_i + (hot_count[name]||0).to_i, created_time)
      end
      counter_names
    end

    # helper methods for point methods

    def hacker_news_point(point, created_time)
      time_intervel = (( Time.now - Time.at(created_time.to_i) ) / (60 * 60)).round
      point.to_f/( (time_intervel == 0 ? 1 : time_intervel) ** (1.1) )
    end

    def convert_global_to_hot_key(global_key)
      tmp_str = global_key.dup
      tmp_str[17..22] = "hot"
      tmp_str
    end

    def created_time_of_key(object_key)
      object_type, object_id = object_key.split(":")[2..3]
      object = object_type.camelize.constantize.where(:id => object_id).first
      object ? object.created_at.to_i : nil
    end

    def point_by_hash(count_hash, weight_hash)
      point = 0
      weight_hash.each do |k, v|
        point += (count_hash[k]||0).to_i * v
      end
      return point
    end
  
    def push_to_result_and_sort(key, member, point)
      LOGGER.debug "------ #{member}  #{point}  -------"
      redis_client.zadd key, point, member
      length = redis_client.zcard key
      redis_client.zremrangebyrank key, 0, 0 if length.to_i > RESULT_MAX_LENTH
    end

    def clear_result_list(key)
      tmp_key = "#{key}_tmp"
      values = redis_client.zrange key, 0, -1, :with_scores => true
      values.each_slice(2) do |args|
        LOGGER.debug " --- backup ----- #{args.inspect} ---------"
        redis_client.zadd tmp_key, *args
      end
      redis_client.zremrangebyrank key, 0, -1
    end

    def reverse_from_tmp_list(key)
      tmp_key = "#{key}_tmp"
      values = redis_client.zrange tmp_key, 0, -1, :with_scores => true
      values.each_slice(2) do |args|
        redis_client.zadd key, *args
      end
      redis_client.del tmp_key
    end
  end
end
