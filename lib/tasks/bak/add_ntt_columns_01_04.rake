#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_ntt_new_01_04 => :environment do
    column  = Column.find(56)
    ["全球经济", "专题"].each do |column_name|
      column.children.create(:name => column_name)
    end
  end
end

