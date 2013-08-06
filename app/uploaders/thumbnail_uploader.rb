# encoding: utf-8

class ThumbnailUploader < BaseUploader
  #include Uploaders::UploaderHelper

  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/articles/thumbnails/#{model.id}"
  end

  #def url(*args)
    #"http://iamges#{rand(3)}.nbd.com.cn/#{super}"
  #end

  # def full_filename(for_file)
  #   if for_file.index(".")
  #     s = for_file.split(".")
  #     [s[0..-2].join(""), version_name, "jpg"].compact.join(".")
  #   else
  #     [for_file, version_name, "jpg"].join("_")
  #   end
  # end


  # def resize_by_width(width)
  #   manipulate! do |img|
  #     img.resize "#{width}x"
  #     img
  #   end
  # end

  version :small do
    process :resize_to_fill => [80, 60]
    process :change_quality
  end

  version :middle do
    process :resize_to_fill => [120, 90]
    process :change_quality
  end

  version :large_a do
    process :resize_to_fill => [270, 176]
    process :change_quality
  end

  version :large_b do
    process :resize_to_fill => [310, 186]
    process :change_quality
  end

  version :x_large do
    process :resize_by_width => [500]
    process :change_quality
  end

  version :thumb_hs do
    process :resize_to_fill => [80, 60]
  end

  version :thumb_hm do
    process :resize_to_fill => [120, 90]
  end

  version :thumb_hl do
    process :resize_to_fill => [300, 225]
  end

  version :thumb_vm do
    process :resize_to_fill => [90, 120]
  end

  version :thumb_vl do
    process :resize_to_fill => [300, 400]
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
