#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_columns_05_15 => :environment do
    # '智库' 频道新增子栏目， "互联网观察"
    column  = Column.find(56)
    ["互联网观察"].each do |column_name|
      column.children.create(:name => column_name)
    end
  end
end

