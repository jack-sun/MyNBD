# encoding: utf-8
class Topic < ActiveRecord::Base
  include CacheCallback::HotResult
  set_table_name "topics"
  HOT_TOPIC_FRAGMENT_CACHE_KEY = "hot_topic_fragment_cache_key"

  default_scope order("pos desc")

  validates_presence_of :title, :message => "标题不能为空"
  validates_uniqueness_of :slug
  
  paginates_per Settings.count_per_page
  
  DRAFT = 0
  PUBLISHED = 1
  BANNDED = 2
  STATUS = {PUBLISHED => "已发布", DRAFT => "草稿", BANNDED => "屏蔽"}
  
  #associations
  belongs_to :staff
  has_many :elements, :as => :owner, :dependent => :destroy
  
  belongs_to :image, :dependent => :destroy
  accepts_nested_attributes_for :image, :reject_if => lambda { |a| a[:topic].blank?}
  
  scope :published, where(:status => PUBLISHED)
  scope :draft, where(:status => DRAFT)
  scope :banned, where(:status => BANNDED)
  
  before_create { generate_slug(:slug) } 
  def generate_slug(column)  
    begin  
      self[column] = SecureRandom.urlsafe_base64(24)
    end while Topic.exists?(column => self[column])  
  end
  
  after_create :init_elements
  def init_elements
    c_weibo = ElementCweibo.new(:title => '微博聚合', :content => {:body => {:tag => self.title, :keywords => []}}.to_json)
    
    self.elements << c_weibo
    self.layout = [{:section_code => 'section_2_b',  :elements => [[c_weibo.id], []]}].to_json
    self.pos = self.id
    self.save
  end
  
  def elements_dict
    dict = {}
    self.elements.each do|e|
      dict.merge!(e.id => e)  
    end
  
    dict
  end
  
  def weibos
    cweibo_element = self.elements.select{|e| e.type == ElementCweibo.name.to_s}.first
    json = JSON.parse(cweibo_element.content)["body"] # if cweibo_element.present?    
    
    Weibo.published.search(json["keywords"], :page => 1, :per_page => 1, :order => :id, :sort_mode => :desc)
  end
  
  def is_banned?
    self.status == BANNDED
  end
  
  def is_published?
    self.status == PUBLISHED
  end
  
  def to_param
    self.slug
  end
  
  class << self
    def hot_tag(limit = 10)
      hot_object_ids("hot_cache:result:hot_tag")
    end
    
    def ban_topic(topic_id)
      self.update_all(["status = ?", BANNDED], ["id = ?", topic_id])
    end
    
    def unban_topic(topic_id)
      self.update_all(["status = ?", PUBLISHED], ["id = ?", topic_id])
    end
    
    def hot_topics(limit)
      where(:status => PUBLISHED).order("pos, id DESC").limit(limit)
    end

    def tag_detail(tag)
      CacheCallback::BaseCallback.tag_detail(tag)
    end

    def change_topic_pos(moved_topic, target_topic)
      Topic.transaction do
        if moved_topic.pos > target_topic.pos
          Topic.update_all("pos = pos + 1", ["pos between ? and ?", target_topic.pos, moved_topic.pos.to_i - 1])
        else
          Topic.update_all("pos = pos - 1", ["pos between ? and ?", moved_topic.pos.to_i + 1, target_topic.pos])
        end
        moved_topic.pos = target_topic.pos
        moved_topic.save!
        return "success"
      end
      return "faild"
    end

  end
  
end
