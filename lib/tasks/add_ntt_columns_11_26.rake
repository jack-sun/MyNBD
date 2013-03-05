#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_columns_11_26 => :environment do
    column  = Column.find(56)
    column.children.create(:name => "说不完的华尔街")
  end
end

