#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_columns_03_05 => :environment do
    # '智库' 频道新增子栏目， "靓眼看华尔街"
    column  = Column.find(56)
    column.children.create(:name => "靓眼看华尔街")
  end
end

