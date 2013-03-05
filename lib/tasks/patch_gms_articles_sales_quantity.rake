#encoding:utf-8
require 'rubygems'
namespace :database do

  task :patch_gms_articles_sales_quantity => :environment do
    puts "======patch begin======"
    gms_account_articles = GmsAccountsArticle.group(:gms_article_id).count
    gms_account_articles.each do |id,count|
      GmsArticle.update(id, :sales_quantity => count)
    end
    puts "======patch done======"
  end

end
