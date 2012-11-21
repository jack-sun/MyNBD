class CacheCallback::FollowingCallback < CacheCallback::BaseCallback
  def self.after_create(following)
    increment_count("followings_count", "user", following.user_id)    
  end
end
