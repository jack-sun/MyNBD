require 'nbd/cache_filter'
module BadwordHelper

  def self.included(base)
    base.extend         ClassMethods
    base.class_eval do
      extend Nbd::CacheFilter
      belongs_to :staff
      after_save :expire_keys_in_cache
      after_destroy :expire_keys_in_cache
      validates_uniqueness_of :value
    end
    base.send :include, InstanceMethods
  end # self.included

  module ClassMethods
    def dict
      find_by_rails_cache_or_db(keyword_list_key) do
        order("id DESC").map(&:value).compact.uniq.join("|")
      end
    end
  end # ClassMethods

  module InstanceMethods
    def expire_keys_in_cache
      Rails.cache.write self.class.keyword_list_key, nil
    end

  end # InstanceMethods

end
