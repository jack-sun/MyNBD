class GalleryImage < ActiveRecord::Base

  belongs_to :gallery
  belongs_to :image, :dependent => :destroy

  attr_accessor :thumb_s_url, :image_url
  attr_accessible :desc, :pos, :image_id

  after_initialize :get_url_infos

  default_scope order(:pos)

  def change_pos(target_pos)
    ori_pos = pos
    target_pos = target_pos.to_i
    gallery_images = gallery.gallery_images
    range = target_pos > ori_pos ? ((ori_pos + 1)..target_pos) : (target_pos...ori_pos)
    query_images = gallery_images.select { |gallery_image| range.include?(gallery_image.pos) }
    GalleryImage.transaction do
      update_attributes!(:pos => target_pos)
      query_images.each { |query_image| query_image.update_attributes!(:pos => (target_pos > ori_pos ? query_image.pos - 1 : query_image.pos + 1)) }
    end
  end

  def sort_for_destroy
    gallery_images = gallery.gallery_images
    range = ((pos + 1)..gallery.max_pos)
    query_images = gallery_images.select { |gallery_image| range.include?(gallery_image.pos) }
    query_images.each { |query_image| query_image.update_attributes!(:pos => (query_image.pos - 1)) }
    gallery.update_attributes!(:max_pos => gallery.max_pos - 1)
  end

  private

  def get_url_infos
    @image_url = image.gal_url if image.present?
    @thumb_s_url = image.gal_url(:thumb_s) if image.present?
  end

end