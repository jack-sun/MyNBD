module Console::ArticlesHelper
	def cahce_test(name = {}, proxyable = false, options = nil, &block)
		Rails.logger.info("==name:#{name},==proxyable:#{proxyable},==options:#{options}")
		unless proxyable
			cache(name, options , &block)
		else
			yield
		end
	end
end
