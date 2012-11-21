# encoding: utf-8

class AdUploader < BaseUploader
  include CarrierWave::MiniMagick
  
  # Include RMagick or ImageScience support: # include CarrierWave::RMagick
  # include CarrierWave::ImageScience
  
  # Choose what kind of storage to use for this uploader:
  # storage :fog
  
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  #def crop(width, height, gravity = "center")
  #manipulate! do |img|
  #img.combine_options do |cmd|
  #cmd.gravity gravity
  #cmd.extent "#{width}x#{height}"
  #end
  #img
  #end
  #end
  
  process :convert => :gif

  def full_filename(for_file)
    if for_file.index(".")
      s = for_file.split(".")
      [s[0..-2].join(""), version_name, "gif"].compact.join(".")
    else
      [for_file, version_name, "gif"].join("_")
    end
  end

  def store_dir
    "uploads/ads/uploads/#{model.id}"
  end

  def unlink_original(file)
    
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
