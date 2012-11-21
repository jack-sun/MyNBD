module Sweepers
  class FeaturePageSweeper < ActionController::Caching::Sweeper

    observe ::FeaturePage

    def expire_feature_nav_fragment(entry)
      expire_cache_object("feature", entry.feature_id)
    end

    alias :after_save :expire_feature_nav_fragment
    alias :after_destroy :expire_feature_nav_fragment
  end
end
