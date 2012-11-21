module CacheCallback
  module HotResult
  
    def self.included(base)
      base.extend         ClassMethods
      base.class_eval do
        
      end
      base.send :include, InstanceMethods
    end # self.included
  
    module ClassMethods
      def hot_object_ids(key)
        CacheCallback::BaseCallback.redis_client.zrevrange key, 0, -1
      end

      def hot_objects(key, limit, asso_hash, delete_ids=[]) 
        ids = (hot_object_ids(key)[0...(limit+delete_ids.count)].map(&:to_i) - delete_ids)[0...limit] 
        self.where(:id => ids).includes(asso_hash).sort_by{|object| ids.index(object.id)} 
      end 

      
    end # ClassMethods
  
    module InstanceMethods
  
    end # InstanceMethods
  
  end
end
