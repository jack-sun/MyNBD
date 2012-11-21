class Portfolio < ActiveRecord::Base
  belongs_to :user
  belongs_to :stock
end

# == Schema Information
#
# Table name: portfolios
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  stock_id   :integer(4)      not null
#  created_at :datetime
#  updated_at :datetime
#

