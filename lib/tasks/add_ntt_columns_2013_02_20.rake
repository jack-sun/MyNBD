#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_columns_2013_02_20 => :environment do
    column  = Column.find(56)
    column.children.create(:name => "我身边的城镇化")
  end
end

