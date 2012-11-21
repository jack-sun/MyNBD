class Jobs::DeletePageCache
  @queue = :delete_page_cache_file 
  def self.perform(class_str, object_id)
    if class_str == "article"
      set = Article.get_page_cache_file_names_set(object_id)
      set.to_a.each do |path|
        File.delete(path) if File.exists?(path)
      end
      Redis::Objects.redis.del set.key
    elsif class_str == "column"
      File.delete(object_id) if File.exists?(object_id)
    end
  end
end
