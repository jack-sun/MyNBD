#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_new_01_12 => :environment do
    # 新增栏目
    column  = Column.find(56)
    ["每经书会"].each do |column_name|
      column.children.create(:name => column_name)
    end
  end
end

