class Ad < ActiveRecord::Base
  belongs_to :ad_position
  belongs_to :image, :dependent => :destroy

  accepts_nested_attributes_for :image , :reject_if => lambda { |a| a[:ad].blank? && a[:remote_ad_url].blank?}

  after_create :update_ad_position
  def update_ad_position
    ad_position = self.ad_position
    ad_position.current_ad = self
    ad_position.save
    cp_image
  end

  after_save :cp_image_after_save
  def cp_image_after_save
    ad_position = self.ad_position
    cp_image if ad_position.current_ad_id == self.id
  end

  def cp_image
    image = self.image
    type = (image_name = image.ad.file.filename).index(".") ? "." + image_name.split(".")[-1] : ""
    if File.exist?("#{Rails.root}/public#{image.ad.to_s}")
      FileUtils.cp "#{Rails.root}/public#{image.ad.to_s}", "#{Rails.root}/public/uploads/ads/display/#{ad_position.name}#{type}"
    end
  end
end
