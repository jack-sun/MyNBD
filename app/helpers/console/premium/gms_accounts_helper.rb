#encoding: utf-8
module Console::Premium::GmsAccountsHelper
	def plan_type_name(plan_type)
		"#{GmsAccount::PLAN_TYPE[plan_type]} (#{GmsAccount::CREDITS[plan_type]}点)"
	end
end
