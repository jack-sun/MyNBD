#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_touzibao_column_09_25 => :environment do
    column = Column.where(:name => "每经手机报").first
    column.children.create(:name => "每经投资宝")
    column.children.create(:name => "投资宝成功案例")
  end
end
