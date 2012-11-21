#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'

namespace :columns do
  task :add_index_columns_05_28 => :environment do
    # “首页” 新增栏目 “专题精选”
    
    column  = Column.find(1)
    ["专题精选"].each do |column_name|
      column.children.create(:name => column_name)
    end

  end
end
