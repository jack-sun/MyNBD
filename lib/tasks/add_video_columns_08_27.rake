#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'

namespace :columns do
  task :add_video_columns_08_27 => :environment do
    # '首页' 频道下新增视听栏目
    # 1. 视听 - 财经面对面， 2. 视听 - 每经财讯
    
    column  = Column.find(1)
    ["视听-财经面对面", "视听-每经财讯"].each do |column_name|
      column.children.create(:name => column_name)
    end

  end
end
