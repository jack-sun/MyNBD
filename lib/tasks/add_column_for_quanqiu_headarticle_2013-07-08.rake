#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_column_for_quanqiu_headarticle_2013_07_08 => :environment do
    column = Column.find(47) #全球
    column.children.create(:name => "头条")
  end
end