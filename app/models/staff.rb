# encoding: utf-8
require "nbd/utils"
class Staff < ActiveRecord::Base
  
  TYPE_ADMIN = 0 #网站技术管理员
  TYPE_EDITOR_ADMIN = 1 #网站编辑管理员
  TYPE_EDITOR = 2 # 网站编辑
  TYPE_COLUMNIST = 3 # 专栏作家
  TYPE_REPORTER = 4 # 记者
  TYPE_PAPER_ADMIN = 5
  
  EDITOER_IN_CHARGE = [TYPE_ADMIN, TYPE_EDITOR_ADMIN, TYPE_EDITOR] # 责任编辑
  
  STATUS_NORMAL = 0
  STATUS_ACTIVE = 1 
  STATUS_BAN = 2

  AUTHORITY_MOBILE_NEWS = 1
  AUTHORITY_COMMON = 2
  AUTHORITY_COMMUNITY = 4
  AUTHORITY_NEWS = 8
  AUTHORITY_STATISTICS = 16
  
  STAFF_TYPE = {TYPE_ADMIN => "网站技术管理员",TYPE_EDITOR => "网站编辑",TYPE_EDITOR_ADMIN => "网站编辑管理员"}
  STATUS_TYPE = {STATUS_ACTIVE => "激活",STATUS_BAN => "屏蔽"}

  AUTHORITIES = [AUTHORITY_NEWS, AUTHORITY_COMMUNITY, AUTHORITY_COMMON, AUTHORITY_MOBILE_NEWS, AUTHORITY_STATISTICS]
  
  validates_presence_of :name,:real_name, :on => :create,:on=>:update, :message => "输入不能为空"
  validates_presence_of :password, :on => :create, :message => "输入不能为空"
  validates_length_of :password, :minimum => 6, :maxium => 20,
    :too_long => "您输入的密码太长，得少于20个字母加数字或字符的组合", :too_short  => "您输入的密码太短，至少得有6个字母加数字或字符的组合",
    :unless => Proc.new{|u| u.password.blank?}
  validates_confirmation_of :password, 
    :message => '两次密码输入不匹配', :if => Proc.new{|u| !u.password.blank?}

  validates_uniqueness_of :name, :real_name

  has_many :columnists
  
  has_many :staffs_permissions
  has_many :columns, :through => :staffs_permissions

  has_many :articles_staffs
  has_many :articles, :through => :articles_staffs

  has_many :newspapers
  has_many :features
  has_many :topics
  has_many :badkeywords
  has_many :badwords

  has_many :touzibaos
  has_many :gms_articles

  has_many :article_logs
  has_many :notices, :dependent => :destroy

  has_many :service_cards

  has_many :polls

  has_many :created_permissions, :class_name => "StaffsPermission", :foreign_key => "creator_id"

  has_many :activated_user_records

  has_many :weibo_logs
  has_many :community_switch_logs
  has_many :charge_columns, :class_name => "Column", :foreign_key => "staff_id_in_charge"

  has_many :staff_convert_logs

  has_many :staff_performance_logs

  has_many :galleries

  scope :reporters, where(:user_type => TYPE_REPORTER)
  scope :common_editors, where(:user_type => TYPE_EDITOR)
  scope :editors_in_charge, where(:user_type => EDITOER_IN_CHARGE)

  attr_accessor :password_confirmation
  attr_reader   :password, :old_password
  
  #before_create :validate_real_name
  before_create { generate_token(:auth_token) } 


  def password=(password)
    @password = password
    
    if password.present?
      generate_salt
      self.hashed_password = self.class.encrypt_password(password, salt)
    end
  end

  def create_article(params, send_weibo = true)
    Article.create_article(params.merge({:staff_ids => [self.id]}), send_weibo)
  end

  def create_gms_article(gms_article_params, article_params)
    top_gms_article = nil
    GmsArticle.transaction do
      pos = Column.find(Column::GMS_ARTICLES_COLUMN).max_pos + 1
      article = create_article(article_params)
      gms_article = GmsArticle.create(gms_article_params.merge!({:staff_id => self.id, :article_id => article.id, :pos => pos})) 
      top_gms_article = gms_article
      top_gms_article.article = article
      if gms_article.valid?
        # gms_article.update_attribute(:article_id,article.id)
      else
        raise ActiveRecord::Rollback, "gms_article is error"
      end
    end
    return top_gms_article
  end

  def create_gms_article_old(gms_params,article)
      GmsArticle.create!(gms_params.merge!({:article_id => article.id,:staff_id => self.id}))
  end

  def create_newspaper(newspapers_data)
    Newspaper.create_newspaper(self, newspapers_data)
  end

  def is_editor?
    self.user_type == TYPE_EDITOR
  end
  
  def is_editor_in_charge?
    EDITOER_IN_CHARGE.include?(self.user_type)
  end
  
  def is_reporter?
    self.user_type == TYPE_REPORTER
  end
  
  def can_monitor_weibo?
    return true
  end
  
  def can_monitor_topic?
    return true
  end
  
  def is_active?
    self.status == STATUS_ACTIVE
  end

  def is_admin?
    [TYPE_ADMIN, TYPE_EDITOR_ADMIN].include?(self.user_type)
  end

  def is_type_editor_admin?
    [TYPE_EDITOR_ADMIN].include?(self.user_type)
  end

  def newspaper_admin?
    [TYPE_PAPER_ADMIN, TYPE_ADMIN].include?(self.user_type)
  end

  def only_newspaper_admin?
    self.user_type == TYPE_PAPER_ADMIN
  end

  def authority_of_news?
    has_authority_of AUTHORITY_NEWS
  end

  def authority_of_community?
    has_authority_of AUTHORITY_COMMUNITY
  end

  def authority_of_common?
    has_authority_of AUTHORITY_COMMON
  end

  def authority_of_mobile_news?
    has_authority_of AUTHORITY_MOBILE_NEWS
  end

  def authority_of_statistics?
    has_authority_of AUTHORITY_STATISTICS
  end

  def add_authority type
    self.permissions = self.permissions | type
    self.save
  end

  def add_authorities types
      permissions_value = 0
      types.each{|x| permissions_value += x.to_i} unless types.nil?
      self.permissions = permissions_value | 0
      self.save
  end


  def delete_authority type
    self.permissions = self.permissions & (~type)
    self.save
  end

  class << self
    
    def authenticate(name, password)
      if user = where(:name => name).first
        if user.is_active? and user.hashed_password == encrypt_password(password, user.salt) 
          user
        end
      end
    end
    
    def encrypt_password(password, salt)
      NBD::Utils.to_md5(password + "nbd-system-2.0" + salt)
    end
    
  end
  

  def ban
    self.update_attribute("status",2)
  end

  def active
    self.update_attribute("status",1)
  end

  private

  def generate_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  def generate_token(column)  
    begin  
      self[column] = SecureRandom.urlsafe_base64(24)
    end while User.exists?(column => self[column])  
  end

  def has_authority_of(type)
    type == self.permissions & type
  end

  def validate_real_name
    dbStaff = Staff.where(:name => self.name)
    unless dbStaff.nil?
    	self.errors.add(:name, "该用户名已经存在，请重新输入!")
    	return false
    end
  end
end




# == Schema Information
#
# Table name: staffs
#
#  id              :integer(4)      not null, primary key
#  name            :string(64)      not null
#  real_name       :string(64)      not null
#  hashed_password :string(32)      not null
#  salt            :string(32)
#  email           :string(64)
#  phone           :string(32)
#  user_type       :integer(4)      default(0)
#  comment         :string(500)
#  status          :integer(4)      default(1), not null
#  creator_id      :integer(4)      default(0), not null
#  created_at      :datetime
#  updated_at      :datetime
#

