#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_hot_subcolumns => :environment do
    # 新增金融，汽车 及子栏目: 热点
    Column.find([119, 129]).each do|parent|
      parent.children.create(:name => "热点")
    end
  end
end

