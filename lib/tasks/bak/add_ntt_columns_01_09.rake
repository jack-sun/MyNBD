#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_new_01_09 => :environment do
    # 1. 修改栏目名称
    zhuanti = Column.find(113)
    zhuanti.name = '2012中国经济展望'
    zhuanti.save!
    
    # 2. 新增栏目
    column  = Column.find(56)
    ["走读台湾", "南亚投资观察"].each do |column_name|
      column.children.create(:name => column_name)
    end
  end
end

