module PaymentAccount
	def total_fee(plan_type)
		self.class::TOTAL_FEE[plan_type]
	end
end