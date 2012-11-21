#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_hot_feature_column_07_13 => :environment do
    # '热点' 频道新增1个子栏目， "精选"
    column  = Column.find(185)
    ["精选"].each do |column_name|
      column.children.create(:name => column_name)
    end
  end
end