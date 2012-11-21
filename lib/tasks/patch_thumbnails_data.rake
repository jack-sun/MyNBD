#encoding:utf-8
require 'rubygems'
require 'nbd/utils'
namespace :image do
  task :patch_thumbnails_data => :environment do
    
    image_count = article_count = 0
    begin_at = image_begin_at = Time.now
    
    #1. patch images table
    Image.find_each(:conditions => "article is not null", :batch_size => 1000) do |e|
      Image.update_all(["thumbnail = ?, article = null", e.read_attribute(:article)], ["id = ?", e.id])
      
      image_count += 1
      
      puts "----------- patch images #{image_count} done" if (image_count % 500) == 0
    end

    puts "---------- patch images done, Time Cost: #{Time.now - image_begin_at} seconds"
    
    article_begin_at = Time.now
    
    #2. patch articles table image_id
    Page. find_each(:conditions => "image_id > 0 AND p_index = 1", :batch_size => 1000) do|p|
      Article.update_all(["image_id = ?", p.image_id], ["id = ?", p.article_id])
      
      article_count += 1
      puts "----------- patch articles #{article_count} done" if (article_count % 500) == 0
    end
    
    
    puts "----------patch articles done, Time Cost: #{Time.now - article_begin_at} seconds"
    
    puts "===== All done, Time Cost: #{Time.now - begin_at} seconds ======"
    
  end
end

