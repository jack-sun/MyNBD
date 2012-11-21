#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_mobile_newspaper_column_09_04 => :environment do
    column = Column.create(:name => "每经手机报")
    column.children.create(:name => "投资快讯")
  end
end
