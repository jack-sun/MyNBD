#encoding: utf-8
class GmsArticle < ActiveRecord::Base
	belongs_to :article , :dependent => :destroy
	belongs_to :staff
	belongs_to :stock, :foreign_key => :stock_code, :primary_key => :code
	validates_presence_of :cost_credits, :stock_code, :stock_name, :message => "输入不能为空"
  	REFUND_STATUS = 1
  	UNREFUND_STATUS = 0
  	PREVIEW_SALE = 1
  	OFFICIAL_SALE = 0
  	scope :published, where(:status => Article::PUBLISHED)
  	scope :on_shelf, where(:is_remove_from_sale => UNREFUND_STATUS)
  	scope :preview, where(:is_preview => PREVIEW_SALE)
  	scope :official, where(:is_preview => OFFICIAL_SALE)
  	scope :to_be_determined, where('meeting_at is null')
  	scope :determined, where('meeting_at is not null')
  	after_save :create_stock
  	after_save :switch_stock_allow_comment

	def published?
		self.status == Article::PUBLISHED
	end

	def banned?
		self.status == Article::BANNDED
	end

	def publish
		GmsArticle.transaction do
			article.publish
			self.update_attribute(:status, Article::PUBLISHED)
		end
	end

	def ban
		GmsArticle.transaction do
			article.ban
			self.update_attribute(:status, Article::BANNDED)
		end
	end

	def user_status?(user)
		return false if user.gms_account.nil?
		gms_account = user.gms_account
		gms_account_article = GmsAccountsArticle.where({:gms_account_id => gms_account.id,:user_id => user.id,:gms_article_id => self.id})
		!gms_account_article.empty?
	end

	def user_gms_article_status(user)
		return GmsAccountsArticle::USER_STATUS_NO_ACCOUNT if user.nil? || user.gms_account.nil? #the user has no gms_account
		gms_account = user.gms_account
		gms_account_article = GmsAccountsArticle.where({:gms_account_id => gms_account.id,:user_id => user.id,:gms_article_id => self.id}).first
		return GmsAccountsArticle::USER_STATUS_NOT_PAID if gms_account_article.nil?	#the user did't buy this gms_article
		gms_article = GmsArticle.find(gms_account_article.gms_article_id)
		if gms_article.is_refund?
			if gms_account_article.is_receive_refund == GmsAccountsArticle::REFUND_CREDITS_STATUS		
				return GmsAccountsArticle::USER_STATUS_RECEIVE_CREDITS 	#the user had taken the credits of this article
			else			
				return GmsAccountsArticle::USER_STATUS_UN_RECEIVE_CREDITS	#the user paid for this article but he didn't take the credits
			end
		else
			return GmsAccountsArticle::USER_STATUS_BOUGHT	#the user paid for this article and the article is work well
		end

	end

	def is_refund?
		is_remove_from_sale == REFUND_STATUS
	end

	def refund_credits
		self.update_attribute(:is_remove_from_sale, REFUND_STATUS)
	end

	def off_shelf?
		is_remove_from_sale == REFUND_STATUS
	end

	def is_preview?
		is_preview == PREVIEW_SALE
	end

	def cost_user_credits(user)
		gms_account_article = GmsAccountsArticle.where({:user_id => user.id,:gms_article_id => self.id}).first
		gms_account_article.cost_credits
	end

	def meeting_at_value(value)
		if self.meeting_at.present?
			self.meeting_at.strftime("%Y-%m-%d")
		else
			value
		end
	end

	def stock_comments_count
		if self.stock.comments_count == 0
		else
			"(#{self.stock.comments_count})"
		end
	end

	def change_pos(target)
		GmsArticle.transaction do
			if self.pos < target.pos
				GmsArticle.update_all("pos = pos-1", :pos => (self.pos + 1) .. target.pos )
			else
				GmsArticle.update_all("pos = pos+1", :pos => target.pos .. (self.pos - 1) )
			end
				self.update_attribute(:pos,target.pos)
		end
	end

	private
	def create_stock
		stock = Stock.where(:code => self.stock_code).first
		stock.update_attributes({:name => self.stock_name}) if stock.present?
		Stock.create({:code => self.stock_code, :name => self.stock_name}) if stock.nil?
	end

	def switch_stock_allow_comment
		stock.update_attribute(:allow_touzibao_comment, self.is_preview)
	end
end
