#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_western_columns => :environment do
     {"西部" => ["头条", "要闻", "图片新闻", "每经访谈", "专题策划", 
         "四川", "重庆", "陕西", "云南", "贵州", "两江新区", "天府新区", "西咸新区", "工业园区", "招商项目", "竞争力",
         "金融", "地产", "公司", "能源", "汽车", "商业", "快消", "IT", "商务会议", "商务旅行", "更多"]}.each do|k, v|
       parent = Column.create(:name => k)
       user = User.create(:nickname => "每经网-#{k}", :password => "nbdnbd", :email => "#{Pinyin.t(k, '')}@nbd.com.cn", :status => 1)
       user.save!
       parent.user = user
       
       v.each do|child|
         parent.children.create(:name => child)
       end
     end
  end
end

