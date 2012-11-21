class CacheCallback::WeiboCallback < CacheCallback::BaseCallback
  def self.after_create(weibo)
    t = Time.now
    increment_count("rt_count", "weibo", weibo.parent_weibo_id) if weibo.parent_weibo_id != 0
    increment_count("rt_count", "weibo", weibo.ori_weibo_id) if weibo.parent_weibo_id != 0 && weibo.parent_weibo_id != weibo.ori_weibo_id
    if weibo.owner_type == "User" && weibo.ori_weibo_id != 0 
      increment_count("rt_count", "user", weibo.owner_id) 
    else
      increment_count("weibo_count", "user", weibo.owner_id) 
    end
    if weibo.ori_weibo_id != 0
      weibo.contain_tags.each do |tag|
        increment_count("rt_weibo_count", tag)
      end
    else
      weibo.contain_tags.each do |tag|
        increment_count("ori_weibo_count", tag)
      end
    end
    LOGGER.debug "------------- cache callback cost time #{Time.now - t}  -----------------"
  end

  def self.after_destroy(weibo)
    t = Time.now
    decrement_count("rt_count", "weibo", weibo.parent_weibo_id) if weibo.parent_weibo_id != 0
    decrement_count("rt_count", "weibo", weibo.ori_weibo_id) if weibo.parent_weibo_id != 0 && weibo.parent_weibo_id != weibo.ori_weibo_id
    if weibo.owner_type == "User" && weibo.ori_weibo_id != 0 
      decrement_count("rt_count", "user", weibo.owner_id) 
    else
      decrement_count("weibo_count", "user", weibo.owner_id) 
    end
    if weibo.ori_weibo_id != 0
      weibo.contain_tags.each do |tag|
        decrement_count("rt_weibo_count", tag)
      end
    else
      weibo.contain_tags.each do |tag|
        decrement_count("ori_weibo_count", tag)
      end
    end
    LOGGER.debug "------------- cache callback cost time #{Time.now - t}  -----------------"
  end
end
