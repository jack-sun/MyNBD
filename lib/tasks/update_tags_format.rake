#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :article do
  task :update_tags_format => :environment do
  	puts "start!================"
  	count = 0
  	total_count = Article.where("tags is not null and tags != ''").count
  	puts "total_count: #{total_count}"
  	Article.where("tags is not null and tags != ''").find_each(:batch_size => 500) do |article|
  		Article.update_all(["tags = ?", "#{NBD::Utils.parse_tags(article.tags).join(',')}"], ["id = ?", article.id])
  		count += 1
  		if count%200 == 0
  			puts "#{count} updated! #{total_count - count} waiting for update!"
  		end
  	end
  	puts "------result-------"
  	puts "total_count:#{total_count}, updated:#{count}"
  	puts "==================end!"
  end
end

