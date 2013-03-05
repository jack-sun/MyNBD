#encoding: utf-8
module Console::Premium::MobileNewspaperAccountsHelper
	def ttyj_plan_type_name(account)
		account.plan_type != MnAccount::PLAN_TYPE_GIFT ? "#{MnAccount::PLAN_TYPE_NAMES[account.plan_type]}" : "#{account.gift_details}"
	end
end
