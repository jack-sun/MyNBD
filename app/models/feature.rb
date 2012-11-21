# encoding: utf-8
class Feature < ActiveRecord::Base
  
  set_table_name "features"
  
  paginates_per Settings.count_per_page
  
  DRAFT = 0
  PUBLISHED = 1
  BANNDED = 2
  STATUS = {PUBLISHED => "已发布", DRAFT => "草稿", BANNDED => "屏蔽"}
  THEME_ARRAY = [["蓝色", "blue"], ["黑色", "black"], ["红色", "red"], ["绿色", "green"]]
  
  has_many :feature_pages, :dependent => :destroy
  has_many :elements, :through => :feature_pages
  has_many :polls, :as => :owner, :dependent => :destroy

  belongs_to :weibo
  has_many :comments, :through => :weibo, :source => :all_comments

  belongs_to :image
  belongs_to :bg_image, :class_name => "Image", :foreign_key => "bg_image_id"
  
  accepts_nested_attributes_for :feature_pages, :allow_destroy => true, :reject_if => lambda { |a| a[:layout].blank? }
  accepts_nested_attributes_for :image, :reject_if => lambda { |a| a[:feature].blank?}
  accepts_nested_attributes_for :bg_image, :reject_if => lambda { |a| a[:feature].blank?}
  validates_presence_of :title
  
  belongs_to :staff
  
  scope :published, where(:status => PUBLISHED)
  scope :draft, where(:status => DRAFT)
  scope :banned, where(:status => BANNDED)
  
  after_create :init_page_and_elements
  
  def init_page_and_elements
    page = FeaturePage.new
    page.title = ''
    page.layout = [].to_json
    #page.pos = 1
    self.feature_pages << page
    
    text = ElementText.new(:title => '文本内容', :content => {:body => '文本'}.to_json)
    page.elements << text
    
    page.layout = [{:section_code => 'section_2_a',  :elements => [[text.id], []]}].to_json
    page.save
  end

  after_create :create_weibo
  def create_weibo
    ori_weibo = User.find(User::SYS_USERS[:feature_user_id]).create_plain_text_weibo("[专题]#{self.title} <a href='http://#{feature_url(self)}'>http://#{feature_url(self)}</a>")
    self.weibo_id = ori_weibo.id
    self.save!
  end

  def feature_url(feature)
    "#{Settings.domain}/features/#{feature.id}"
  end

  def is_allow_comment?
    self.allow_comment == 1 ? true : false
  end

  def feature_theme
    return "default" if self.theme == "default"
    return "" if self.theme.blank?
    JSON.parse(self.theme)["theme"]
  rescue JSON::ParserError
    return self.theme
  end

  def feature_bg_color
    return "" if self.theme == "default"
    return "" if self.theme.blank?
    JSON.parse(self.theme)["color"]
  rescue JSON::ParserError
    return "" # ignore the theme value when not saved in json format. modified by Vincent at 2012-10-22
    #return self.theme
  end

#  def to_param
#    self.slug
#  end

  def is_published?
    self.status == PUBLISHED
  end

  def change_to_published
    self.status = PUBLISHED
    self.save!
  end

  def change_to_draft
    self.status = DRAFT
    self.save!
  end
  
end
