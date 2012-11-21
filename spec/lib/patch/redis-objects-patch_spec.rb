require File.expand_path('spec/spec_helper')
require "patch/redis-objects-patch"

describe Redis::Objects do
  it "test patch" do
    user = Factory.create(:user)
    #user.cache_user_info[:a] = "b"
    puts User.get_cache_user_info_hash_key(user.id).clear
  end
end
