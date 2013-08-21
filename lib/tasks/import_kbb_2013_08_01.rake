#encoding:utf-8
require 'rubygems'
require 'chinese_pinyin'
require 'nbd/utils'

namespace :koubeibang do
  task :import_kbb_2013_08_01 => :environment do
      [ "最具竞争优势上市公司",
        "最佳内部治理上市公司",
        "最具成长潜力上市公司",
        "最佳股东回报上市公司",
        "最佳环境贡献上市公司",
        "最佳商业模式上市公司",
        "最佳董秘",
        "最佳管理团队上市公司"
      ].each do|title|
        Koubeibang.create(:title => title, :k_index => "2013", :desc => title, :kbb_candidates_count => 10)
      end
  end
end