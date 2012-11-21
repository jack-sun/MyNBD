class CacheCallback::CommentCallback < CacheCallback::BaseCallback
  def self.after_create(comment)
    t = Time.now
    increment_count("comment_count", "weibo", comment.weibo_id)
    increment_count("comment_count", "weibo", comment.ori_weibo_id) if comment.ori_weibo_id != comment.weibo_id
    increment_count("comment_count", "user", comment.user_id)

    weibo = comment.weibo
    increment_count("comment_count", "article", comment.article_id) if comment.article_id

    weibo.contain_tags.each do |tag|
      increment_count("ori_comment_weibo_count", tag)
    end
    comment.contain_tags.each do |tag|
      increment_count("comment_count", tag)
    end
    LOGGER.debug "------------- cache callback cost time #{Time.now - t}  -----------------"
  end  

  def self.after_destroy(comment)
    t = Time.now
    decrement_count("comment_count", "weibo", comment.weibo_id)
    decrement_count("comment_count", "weibo", comment.ori_weibo_id) if comment.ori_weibo_id != comment.weibo_id
    decrement_count("comment_count", "user", comment.user_id)

    weibo = comment.weibo
    decrement_count("comment_count", "article", comment.article_id) if comment.article_id

    weibo.contain_tags.each do |tag|
      decrement_count("ori_comment_weibo_count", tag)
    end
    comment.contain_tags.each do |tag|
      decrement_count("comment_count", tag)
    end
    LOGGER.debug "------------- cache callback cost time #{Time.now - t}  -----------------"
  end  
end
