#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :weibo do
  
  task :create_col_sys_accounts => :environment do
    #columns = ["首页", "新闻", "市场", "商业", "全球", "观点", "生活", "管理", "其他"]
    
    columns = Column.find_by_sql(["SELECT * FROM columns WHERE parent_id is NULL"])
    
    columns.each do|column|
      user = User.create(:nickname => "每经网-#{column.name}", :password => "nbd5395", :email => "#{Pinyin.t(column.name, '')}@nbd.com.cn", :status => 1, :user_type => 0)
      user.save!
      
      column.user = user
    end
  end
  
  task :create_stock_live_account => :environment do
     user = User.new
     user.id = 10347
     user.nickname = '每经网-股市直播'
     user.password = "nbd5395"
     user.email = 'zhibo@nbd.com.cn'
     user.status = 1
     user.user_type = 0
     
     user.save!
  end
  
  
  
  
end
