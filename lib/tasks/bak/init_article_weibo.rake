namespace :article do
  task :add_weibo_cache => :environment do
    last_article = Article.where(:weibo_id => 0).order("id asc").first
    Article.find_in_batches(:batch_size => 1000) do |articles|
      start_time = Time.now
      temp_hash = {}
      articles.each do |article|
        temp_hash[article.weibo_id] = article.id unless article.weibo_id == 0
      end
      next if temp_hash.blank?
      Weibo.weibo_article_id.bulk_set(temp_hash)
      puts "---------  cost time  -----------#{Time.now - start_time}-------------------------"
    end
  end
end
