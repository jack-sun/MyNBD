require "redis"
require 'redis/objects'
require "redis-store"

#configuration for rails cache store
#Nbd::Application.config.cache_store = :redis_store, Settings.redis_cache_store

#configuration for redis obj store
Redis::Objects.redis = Redis.new(Redis::Factory.convert_to_redis_client_options(Settings.redis_cache_store))

# patch for redis objects
# if the method is not a global method
# the pathc will define a class method
# to get redis object by the AR instance id
#
# example:
# class User
#   counter :cache_follower
#   list :followers
# end
#
# this will define methods
# *get_cache_follower_counter*
# *get_follower_list*
#
#  User.get_cache_follower_counter(user.id) will return the user's cache_follower
#  User.get_follower_list(user.id) will return the user's followers
#

require 'active_support/inflector'
class Redis
  module Objects

    class << self

      def included(klass)
        # Core (this file)
        klass.instance_variable_set('@redis', @redis)
        klass.instance_variable_set('@redis_objects', {})
        klass.send :include, InstanceMethods
        klass.extend ClassMethods

        # Pull in each object type
        klass.send :include, Redis::Objects::Counters
        klass.send :include, Redis::Objects::Lists
        klass.send :include, Redis::Objects::Locks
        klass.send :include, Redis::Objects::Sets
        klass.send :include, Redis::Objects::SortedSets
        klass.send :include, Redis::Objects::Values
        klass.send :include, Redis::Objects::Hashes

        #patch for class methods
        klass.send :include, ClientPatch
      end
    end

    module ClientPatch
      def self.included(base)
        ["counter", "list", "sorted_set", "set", "hash_key", "value"].each do |method_name|
          base.instance_eval <<-OutMethod
            def #{method_name}(name, options={})
              super
              unless options[:global]
                instance_eval <<-EndMethod
                  def get_\#{name}_#{method_name}(id)
                    Redis::#{method_name.camelize}.new(redis_field_key("\#{name}", id), self.redis)
                  end
                EndMethod
              end
            end
          OutMethod
        end
      end
    end
  end
end
