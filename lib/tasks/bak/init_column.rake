##encoding:utf-8
#require 'rubygems'
#require 'chinese_pinyin'
#require 'nbd/utils'
#namespace :column do
#  task :init => :environment do
#    {"首页" => ["头条", "要闻", "图片新闻", "每日精选"],
#    "新闻" => ["头条", "热点", "每日精选"],
#    "市场" => ["头条", "行情快讯", {"今日导读" =>  ["今日交易提示", "机构评级", "揭秘龙虎榜", "公告速递", "资金流向", "特色数据", "研究报告", "年报掘金", "晨报精读"]}, "股票", "基金", "期货", "外汇", "债券", "大宗商品", "分析及评论", "专栏", "IPO调查", "上市公司调查"],
#    "商业" => ["头条", "热点", "精选", "金融", "房产", "科技", "汽车", "能源", "工业", "航空和运输", "宏观", "消费品", "传媒与文化"],
#    "全球" => ["全球快讯", "美国", "英国", "欧洲", "亚太", "美洲", "亚洲", "全球精选"],
#    "观点" => ["头条", "专栏", "评论", "记者手记"],
#    "生活" => ["头条", "娱乐", "时尚", "旅行", "品位", "理财", "读书", "生活精选"],
#    "管理" => ["头条", "职场", "人物", "商学院", "管理前沿", "管理精选"]
#    }.each do |k, v|
#      parent = Column.create(:name => k)
##      user = User.create(:nickname => "每经网-#{k}", :password => "nbdnbd", :email => "#{Pinyin.t(k, '')}@nbd.com.cn", :status => 1)
##      user.save!
##      parent.user = user
#      v.each do |child|
#        if child.is_a?(String)
#          parent.children.create(:name => child)
#        elsif child.is_a?(Hash)
#          
#          child.each do|c_k, c_v|
#            c = parent.children.create(:name => c_k)
#            
#            c_v.each do|c_v_child|
#              c.children.create(:name => c_v_child)
#            end
#          end
#          
#        end  
#      end
#    end
#  end
#end
