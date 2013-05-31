#encoding: utf-8
module Console::Premium::MobileNewspaperAccountsHelper
	def ttyj_plan_type_name(account)
		account.plan_type != MnAccount::PLAN_TYPE_GIFT ? "#{MnAccount::PLAN_TYPE_NAMES[account.plan_type]}" : "#{account.gift_details}"
	end

	def plan_type_str(mn_account)

	# if self.plan_type == PLAN_TYPE_GIFT
	#   return "#{ACTIVE_FROM[self.last_active_from]}-赠送"
	# else
	#   return "#{ACTIVE_FROM[self.last_active_from]}"
	# end
		return "#{MnAccount::ACTIVE_FROM[mn_account.last_active_from]}#{mn_account.plan_type == MnAccount::PLAN_TYPE_GIFT ? '-赠送' : ''}"
	end	
end
