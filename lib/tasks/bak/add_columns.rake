#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_new => :environment do
    
    #1： 新增 首页/视频新闻 栏目
    home_parent = Column.find(1)
    home_parent.children.create(:name => "视频新闻") # id must be 90
    
    #2： 每个 “根栏目” 下面都增加一个“更多”的子栏目，用于放置 栏目配稿
    Column.find_by_sql("SELECT * FROM columns where parent_id is null").each do|parent|
      parent.children.create(:name => "更多")
    end
  end
end
