#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_touzibao_column_2013_04_25 => :environment do
    column = Column.find 197 #每经手机报（频道），即：投资宝
    column.children.create(:name => "新闻报道")
    column.children.create(:name => "读者沙龙")
  end
end
