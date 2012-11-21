#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_columns_10_22 => :environment do
    # '智库' 频道新增 研究报告具体栏目：重磅推荐，晨会速递，热门研报, LED，物联网，钒钛， 新源
    column  = Column.find(56)
    ["重磅推荐", "晨会速递", "热门研报", "LED", "物联网", "钒钛", "新能源"].each do |column_name|
      column.children.create(:name => column_name)
    end
  end
end

