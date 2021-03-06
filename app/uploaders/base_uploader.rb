require 'carrierwave/storage/sftp'
class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  after :store, :unlink_original
  # storage :file
  storage :sftp

  def unlink_original(file)
    File.delete("#{Rails.root}/public#{model.send(model.url_type)}") if !self.class.versions.first.nil? and File.exist?("#{Rails.root}/public#{model.send(model.url_type)}")
  end

  #def check_size(file)
  #raise ImageLargeError if file.size > 2*1024
  #end


  #  def store_dir
  #    "uploads/articles/#{model.id}"
  #  end

  def url(*args)
    hash = args.extract_options!.symbolize_keys!
    ori_url = super(*args)
    result = ori_url =~ /^http:/ ? ori_url : "http://image#{[nil, 1, 2][rand(3)]}#{Settings.session_domain}#{super}" 
    if hash[:subdomain]
      return result.sub(/image\d?/, hash[:subdomain])
    end
    result
  end
  
  def full_filename(for_file)
    if for_file.index(".")
      s = for_file.split(".")
      [s[0..-2].join(""), version_name, "jpg"].compact.join(".")
    else
      [for_file, version_name, "jpg"].join("_")
    end
  end

  def resize_by_width(width)
    manipulate! do |img|
      img.resize "#{width}x"
      img
    end
  end
  
  def change_quality
    manipulate! do |img|
      img.quality "80"
      img.strip
      img
    end
  end

  CarrierWave.configure do |config|
    config.sftp_host = "#{Settings.remote_image_sftp_host}"
    config.sftp_user = "#{Settings.remote_image_sftp_user}"
    config.sftp_folder = "#{Settings.remote_image_sftp_folder}"
    config.sftp_url = ""
    config.sftp_options = {
      :port     => 22
    }
  end

end
class ImageLargeError < UploaderError; end
