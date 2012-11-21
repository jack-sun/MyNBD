#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_columns_06_15 => :environment do
    # '智库' 频道新增子栏目， "楼市观察"
    column  = Column.find(56)
    ["楼市观察"].each do |column_name|
      column.children.create(:name => column_name)
    end
  end
end

