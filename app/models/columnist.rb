require 'chinese_pinyin'
class Columnist < ActiveRecord::Base
  EXPIRE_IN = 24*60*60
  belongs_to :image, :dependent => :destroy
  has_many :articles_columnists, :dependent => :destroy
  has_many :articles, :through => :articles_columnists

  belongs_to :last_article, :class_name => "Article"

  belongs_to :staff

  accepts_nested_attributes_for :image , :reject_if => lambda { |a| a[:columnist].blank? && a[:remote_columnist_url].blank?}

  validates_uniqueness_of :slug

  before_save :init_slug
  def init_slug
    self.slug = Pinyin.t(self.name, "_") if self.slug.blank? or self.name_changed?
  end

  def to_param
    self.slug
  end

  def update_last_article
    self.last_article_id = self.articles_columnists.order("id desc").first.try(:article_id)
    self.save!
  end
end
