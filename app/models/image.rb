require 'file_size_validator'
require 'open-uri'
class Image < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  mount_uploader :article, ArticleUploader 
  mount_uploader :feature, FeatureUploader
  mount_uploader :avatar, AvatarUploader
  mount_uploader :topic, TopicUploader
  mount_uploader :columnist, ColumnistUploader
  mount_uploader :ad, AdUploader
  mount_uploader :thumbnail, ThumbnailUploader
  mount_uploader :gal, GalUploader

  IMAGE_LIMIT = 1024*1024*2

  validates :article, :feature, :avatar, :topic, :columnist, :thumbnail, :gal, :file_size => {:maximum => IMAGE_LIMIT, :message => "the image is too large"}  
  TYPE_ARTICLE = 0
  TYPE_AVATAR = 1
  TYPE_WEIBO = 2
  TYPE_FEATURE = 3
  TYPE_TOPIC = 4
  TYPE_COLUMNIST = 5
  TYPE_AD = 6
  TYPE_GALLERY = 7

  ACTION_UPDATE = 1
  ACTION_DESTROY = 2

  URL_TYPE = {"article" => "x_large", "feature" => nil, "gal" => "thumb_s"}
  
  IMAGE_TYPE = {TYPE_ARTICLE => "articles", TYPE_AVATAR => "avatars", TYPE_WEIBO => "weibos", TYPE_FEATURE => "features", 
                TYPE_TOPIC => "topics", TYPE_COLUMNIST => "columnist" , TYPE_AD => "ad", TYPE_GALLERY => "gal"}

  ARTICLE_PROCESSED_NAME = "article_processed"
  GALLERY_PROCESSED_NAME = "gallery_processed"
  GALLERY_THUMB_NAME = "gallery_thumb"
  THUMBNAIL_THUMB_HS_NAME = "thumbnail_thumb_hs"      
  THUMBNAIL_THUMB_HM_NAME = "thumbnail_thumb_hm" 
  THUMBNAIL_THUMB_HL_NAME = "thumbnail_thumb_hl" 
  THUMBNAIL_THUMB_VM_NAME = "thumbnail_thumb_vm" 
  THUMBNAIL_THUMB_VL_NAME = "thumbnail_thumb_vl" 

  ARTICLE_VERSIONS = [ARTICLE_PROCESSED_NAME]
  GALLERY_VERSIONS = [GALLERY_PROCESSED_NAME, GALLERY_THUMB_NAME]
  THUMBNAIL_VERSIONS = [THUMBNAIL_THUMB_HS_NAME, THUMBNAIL_THUMB_HM_NAME, THUMBNAIL_THUMB_HL_NAME, 
                        THUMBNAIL_THUMB_VM_NAME, THUMBNAIL_THUMB_VL_NAME]

  VERSIONS_SIZE = { ARTICLE_PROCESSED_NAME => "500x500", GALLERY_PROCESSED_NAME => "1280x1280", 
               GALLERY_THUMB_NAME => "300x225", THUMBNAIL_THUMB_HS_NAME => "80x60", 
               THUMBNAIL_THUMB_HM_NAME => "120x90", THUMBNAIL_THUMB_HL_NAME => "300x225", 
               THUMBNAIL_THUMB_VM_NAME => "90x120", THUMBNAIL_THUMB_VL_NAME => "300x400" }

  VALID_COLUMNS = [:article, :avatar, :feature, :topic, :columnist, :thumbnail, :gal]

  attr_accessor :image_width, :image_height, :action, :raw_desc

  has_one :ori_page, :class_name => "Page"
  has_one :ori_user, :class_name => "User"
  has_one :ori_element, :class_name => "ElementImage"
  has_one :ori_topic, :class_name => "Topic"

  define_index do
    # fields
    indexes :desc

    # attributes
    has :id, created_at, updated_at
    
    # 声明使用实时索引 
    set_property :delta => true
    
    #where "article is not NULL OR thumbnail is not NULL"
  end
  
  def to_jq_upload(type, url_subdomain = nil)
    {
      "name" => read_attribute("#{type}_name"),
      "size" => send(type).size,
      "url" => send(type).url(URL_TYPE[type.to_s], :subdomain => "image"),
      "delete_url" => console_image_path(:id => id),
      "image_id" => id,
      "delete_type" => "DELETE" ,
      "image_desc" => self.desc
     }
  end

  def url_for_search(type = nil, subdomain = nil)
    send("#{self.url_type}_url", type, :subdomain => subdomain)
  end

  def url_type
    if self.new_record?
      VALID_COLUMNS.find{|x| self.send(x).present? }
    else
      VALID_COLUMNS.find{|x| self.read_attribute(x).present? }
    end
  end

  def clear_uploader(name)
    write_attribute(name, nil)
    self.save!
  end

  def nbd_image_height(type)
    self.image_width_or_height(type, :height)
  end

  def nbd_image_width(type)
    self.image_width_or_height(type, :width)
  end

  def remote_url(image_type)
    "#{::Settings.local_image_host}#{self.send(image_type)}"
  end

  def image_width_or_height(image_type, attr_type)
    # MiniMagick::Image.open(self.send(image_type).file.file)[attr_type]
    MiniMagick::Image.open(remote_url(image_type))[attr_type]
  rescue StandardError
    return 0
  end

  def self.version_name_and_size(model)
    version_name_and_size = {}
    Image.const_get("#{model.upcase}_VERSIONS").each do |version_name|
      if version_name == "#{model}_processed"
        final_name = ""
      else
        final_name = version_name.sub("#{model}_", "")
      end
      version_name_and_size[final_name] = VERSIONS_SIZE[version_name]
    end
    return version_name_and_size
  end

  #after_save :touch_the_object
  #def touch_the_object
    #{"article" => "page", "avatar" => "user", "feature" => "element", "topic" => "topic"}.each do |name, value|
      #if send("#{name}_changed?")
        #object = send("ori_#{value}")
        #object.updated_at = Time.now
        #object.save!
        #break
      #end
    #end
  #end
 
#  after_destroy :remove_image_file
#  def remove_image_file
#    VALID_COLUMNS.each do|column|
#      if self[column].present?
#        logger.debug "----------- #{self.send(column.to_s + "_url")}"  
#      end
#    end
#  end
  
end
