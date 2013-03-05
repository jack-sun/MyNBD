#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_column_for_touzibao_gms_2012_12_25 => :environment do
    column = Column.find(197) #每经手机报
    column.children.create(:name => "股东大会实录")
  end
end