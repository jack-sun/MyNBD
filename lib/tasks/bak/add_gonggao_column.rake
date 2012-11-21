#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_gonggao_column => :environment do
    # 新增栏目, "首页" - “公告”
    Column.find(1).children.create(:name => "公告")
  end
end

