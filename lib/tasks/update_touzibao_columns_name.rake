#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'
namespace :column do
  task :update_touzibao_column_names => :environment do
    touzibao = Column.find 197 #每经手机报（频道），即：投资宝
    touzibao.name = "每经投资宝"
    touzibao.console_display = 1
    touzibao.save

    ttyj = Column.find 199
    ttyj.name = '天天赢家'
    ttyj.console_display = 0
    ttyj.save

    tzkx = Column.find 198
    tzkx.console_display = 0
    tzkx.save

    gsm = Column.find 210
    gsm.console_display = 0
    gsm.save

    cgal = Column.find 200
    cgal.name = "成功案例"
    cgal.save

  end
end
