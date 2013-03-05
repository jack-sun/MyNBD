class Stock < ActiveRecord::Base
  has_many :portfolios
  has_many :followers, :through => :portfolios, :source => :user
  has_many :weibos, :as => :owner
  has_many :gms_articles, :foreign_key => :stock_code, :primary_key => :code
  has_many :stock_comments, :foreign_key => :stock_code, :primary_key => :code
  PREVIEW_SALE = 1
  OFFICIAL_SALE = 0
  def create_weibo(new_weibo_params)
    self.weibos.create(new_weibo_params)
  end
  
  def is_preview?
	allow_touzibao_comment == PREVIEW_SALE
  end  

  def preview_gms_article
    self.gms_articles.preview.order('id desc').first
  end
end


# == Schema Information
#
# Table name: stocks
#
#  id              :integer(4)      not null, primary key
#  name            :string(32)      not null
#  code            :string(32)      not null
#  followers_count :integer(4)
#  weibos_count    :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#

