module Sweepers
  class ElementSweeper < ActionController::Caching::Sweeper
    observe ::Element


    def after_save(entry)
      if entry.owner.is_a? FeaturePage
        feature_id = entry.owner.feature_id
        key = "views/#{feature_element_content_key_by_id_and_element_id(feature_id, entry.id, false)}"
        nbd_expire_fragment_key(key)
      end
    end

    def after_destroy(entry)
      if entry.owner.is_a? FeaturePage
        feature_id = entry.owner.feature_id
        key = "views/#{feature_element_content_key_by_id_and_element_id(feature_id, entry.id, false)}"
        nbd_expire_fragment_key(key)
      end
    end
  end
end
