#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'

namespace :columns do
  task :add_club_columns_05_09 => :environment do
    # '每经会' 相关栏目
    # 1. 头条  2. 活动快讯   3. 品牌活动 4.每经沙龙   5. 每经公益   6. 每经讲堂
    {"每经会" => ["头条", "活动快讯", "品牌活动", "每经沙龙", "每经公益", "每经讲堂"]}.each do|k, v|
      
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
