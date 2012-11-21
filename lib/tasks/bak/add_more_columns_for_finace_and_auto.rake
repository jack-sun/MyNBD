#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_more_columns_for_finace_and_auto => :environment do
    
    # 为‘金融’, '汽车' 频道增加 '更多' 栏目
    Column.find([119, 129]).each do|parent|
      parent.children.create(:name => "更多")
    end
  end
end
