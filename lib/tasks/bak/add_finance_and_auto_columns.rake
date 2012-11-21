#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :add_finance_and_auto_columns => :environment do
    # 新增金融，汽车频道及各子栏目
     {"金融" => ["头条", "精选", "银行", "保险", "外汇", "基金", "债券", "理财", "银行产品"],
      "汽车" => ["头条", "精选", "新车", "行情", "测评", "导购", "自驾", "安全", "二手车"]
     }.each do|k, v|
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

