class Stock < ActiveRecord::Base
  has_many :portfolios
  has_many :followers, :through => :portfolios, :source => :user
  has_many :weibos, :as => :owner
  
  def create_weibo(new_weibo_params)
    self.weibos.create(new_weibo_params)
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

