#encoding:utf-8
class CreditLog < ActiveRecord::Base
	belongs_to :user
	# belongs_to :product, :polymorphic => :true


	CMD_COST = 0
	CMD_PAY = 1  
	CMD_REFUND = 2
	CMD_RECEIVE = 3

	PRODUCT_TYPE_GMS = 1
	PRODUCT_TYPE_MN = 0
end
