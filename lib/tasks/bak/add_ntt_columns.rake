#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_new => :environment do
    #2： 每个 “根栏目” 下面都增加一个“更多”的子栏目，用于放置 栏目配稿
    column  = Column.find(56)
    ["智库专家", "专家访谈", "经济大势", "区域经济", "商业评论", "投资策略", "公共治理", "专家活动", "研究报告", "市场数据", "投资研究"].each do |column_name|
      column.children.create(:name => column_name)
    end
  end
end

