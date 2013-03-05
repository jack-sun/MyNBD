#encoding: utf-8
class StockComment < ActiveRecord::Base
	# belongs_to :stock, :foreign_key => :stock_code#, :conditions => 'code = #{stock_code}'
	belongs_to :user
	after_create :create_stock
	before_destroy :decrement_comment_count

	validates_presence_of :stock_code, :stock_name, :comment, :message => "输入不能为空"
	# paginates_per 15
	scope :banned, where(:status => 1)
	scope :published, where(:status => 0)
	STATUS = { 0 => '已发布', 1 => '已屏蔽'}

	def is_banned?
		status == 1
	end

	def ban
		StockComment.transaction do
			self.update_attribute(:status,1)
			decrement_comment_count
		end
	end

	def publish
		StockComment.transaction do
			self.update_attribute(:status,0)
			stock = Stock.where(:code => self.stock_code).first
			stock.increment!("comments_count")
		end
	end

	private
	def create_stock
		stock = Stock.where(:code => self.stock_code).first
		stock = Stock.create({:code => self.stock_code, :name => self.stock_name}) if stock.nil?
		stock.increment!("comments_count")
	end

	def decrement_comment_count
		stock = Stock.where(:code => self.stock_code).first
		stock.decrement!("comments_count")
	end
end


