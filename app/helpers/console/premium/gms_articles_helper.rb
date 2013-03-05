#encoding: utf-8
module Console::Premium::GmsArticlesHelper
	def gms_article_sale_status(gms_article)
		if gms_article.off_shelf?
			"<span>已下架</span>"
		else
			if gms_article.is_preview?
				"<span>预售</span>"
			else
				"<span>正式发售</span>"
			end
		end
	end
end
