module ColumnsHelper
	def adjust_head_article_digest_height(children_articles_title_length)
		if children_articles_title_length == 0
			return "129px;"
		elsif children_articles_title_length <= 24
			return "107px;"
		elsif children_articles_title_length <= 48
			return "85px;"
		else
			return "63px;"
		end
	end
end
