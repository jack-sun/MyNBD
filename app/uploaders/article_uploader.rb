# encoding: utf-8

class ArticleUploader < BaseUploader

  #include Uploaders::UploaderHelper

  # Include RMagick or ImageScience support:
  # include CarrierWave::RMagick
  # include CarrierWave::ImageScience

  # Choose what kind of storage to use for this uploader:
  # storage :fog
  before :cache, :capture_size_before_cache # callback, example here: http://goo.gl/9VGHI 
  def capture_size_before_cache(new_file) 
    if model.image_width.nil? || model.image_height.nil?
      model.image_width, model.image_height = `identify -format "%wx %h" #{new_file.path}`.split(/x/).map { |dim| dim.to_i }
    end
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  process :change_quality
  def store_dir
    "uploads/articles/images/#{model.id}"
  end

  # def url(*args)
  #   "http://iamges#{rand(3)}.nbd.com.cn/#{super}"
  # end

  # def full_filename(for_file)
  #   if for_file.index(".")
  #     s = for_file.split(".")
  #     [s[0..-2].join(""), version_name, "jpg"].compact.join(".")
  #   else
  #     [for_file, version_name, "jpg"].join("_")
  #   end
  # end

  def resize_by_width(width)
    if model.image_width > 500
      manipulate! do |img|
        img.resize "#{width}x"
        img
      end
    end
  end

  process :resize_to_limit => [500, 500]#, :if => :is_height_or_width_over_500?

  # version :small do
  #   process :resize_to_fill => [80, 60]
  # end

  # version :middle do
  #   process :resize_to_fill => [120, 90]
  # end

  # version :large_a do
  #   process :resize_to_fill => [270, 176]
  # end

  # version :large_b do
  #   process :resize_to_fill => [310, 186]
  # end

  version :x_large do
    process :resize_by_width => [500]
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
