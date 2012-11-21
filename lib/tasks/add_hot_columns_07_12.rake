#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_hot_columns => :environment do
    # 新建 “热点” 频道
    #  热点 => 焦点新闻（头条）；体娱圈；大千世界；曝光台；奇闻异事；健康风尚；教育资讯

     {"热点" => ["焦点新闻", "体娱圈", "大千世界", "曝光台", "奇闻异事", "健康风尚", "教育资讯"]}.each do|k, v|
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