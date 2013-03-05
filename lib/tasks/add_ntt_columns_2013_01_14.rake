#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_columns_2013_01_14 => :environment do
    column  = Column.find(56)
    column.children.create(:name => "2013经济展望")
  end
end

