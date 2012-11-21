#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_columns_02_28 => :environment do
    # '智库' 频道新增两个子栏目， "两会议什么？", "中国改革的方向"
    column  = Column.find(56)
    ["两会议什么?", "中国改革的方向"].each do |column_name|
      column.children.create(:name => column_name)
    end
  end
end

