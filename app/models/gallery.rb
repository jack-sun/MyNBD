# encoding: utf-8
require 'nbd/utils'

class Gallery < ActiveRecord::Base

  include CacheCallback::HotResult

  has_many :gallery_images, :dependent => :destroy
  belongs_to :staff
  has_many :articles, :dependent => :destroy

  STATUS_UNPUBLISH = 0
  STATUS_PUBLISHED = 1

  STATUS_TYPE = { STATUS_UNPUBLISH => "未发布", STATUS_PUBLISHED => "已发布" }

  attr_accessible :title, :desc, :tags, :watermark, :status, :max_pos, :click_count
  attr_accessor :thumb_url

  define_index do
    indexes tags
    has :id, status, created_at, updated_at, click_count
    set_property :delta => true
  end

  validates :title, :presence => true

  before_save :parse_tags
  after_find :get_url_infos

  def update_with_gallery_images(gallery_params)
    gallery_images_params_keys = gallery_params.keys.select { |key| key =~ /gallery_images_(\d)+/ }
    Gallery.transaction do
      if gallery_images_params_keys.present?
        gallery_images_params_keys.each do |key|
          gallery_images_params = gallery_params[key]
          id = key.split("_").last.to_i
          desc = gallery_images_params["desc"]
          gallery_image = GalleryImage.where(:id => id).first
          gallery_image.update_attributes!(:desc => desc)
        end
      end
      update_attributes!(gallery_params.delete_if { |k, v| k =~ /gallery_images_/ })
    end
  end

  def increase_click_count
    update_attributes(:click_count => click_count + 1)
  end

  def generate_gallery_image(params_hash)
    gallery_size = max_pos
    upload_images_size = params_hash.size
    new_gallery_images = []
    Gallery.transaction do
      params_hash.each_with_index do |arrayed_hash, index|
        new_gallery_images << gallery_images.create!(:image_id => arrayed_hash.first, :desc => arrayed_hash.last[:desc], 
                                                     :pos => gallery_size + index + 1)
      end
      update_attributes!(:max_pos => (gallery_size + upload_images_size))
    end
    return new_gallery_images
  end

  def recommend_galleries
    return [] if tags.blank?
    parsed_tags = NBD::Utils.parse_search_tags(tags)
    recommend_galleries = Gallery.search(:page => 1, :per_page => Settings.recommend_galleries_num, 
                                         :order => 'id desc', :with => {:status => STATUS_PUBLISHED}, 
                                         :without => {:id => id}, :conditions => {:tags => "(#{parsed_tags.join(' | ')})"})
    return recommend_galleries
  end

  def self.hot_galleries(limit = Settings.hot_galleries_num, asso_hash = {})
    hot_objects(CacheCallback::BaseCallback::HOT_GALLERY_KEY, limit, asso_hash)
  end

  private

  def parse_tags
    self.tags = NBD::Utils.parse_tags(self.tags).join(",") unless self.tags.blank?
  end

  def generate_gallery_images(params_hash)
    gallery_size = max_pos
    upload_images_size = params_hash.size
    Gallery.transaction do
      params_hash.each_with_index do |arrayed_hash, index|
        gallery_images.create!(:image_id => arrayed_hash.first, :desc => arrayed_hash.last[:desc], :pos => gallery_size + index + 1)
      end
      update_attributes!(:max_pos => (gallery_size + upload_images_size))
    end
  end

  def get_url_infos
    @thumb_url = gallery_images.first.image.gal_url(:thumb_s) if gallery_images.present?
  end

end