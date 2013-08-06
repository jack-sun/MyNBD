require 'nbd/image_new_versions_generator'
require 'redis'

class Jobs::GenerateNewVersionsForNewArticles


  @queue = :article_fragment_static_page
  def self.perform
    puts "======generate new versions for new articles begin======"

    Dir.mkdir("tmp_pics") unless Dir.exist?("tmp_pics")

    redis_client = Redis.new(Redis::Factory.convert_to_redis_client_options(Settings.redis_cache_store))

    image_new_version_id = redis_client.get("image_new_version_id")

    add_version_models = ["article", "thumbnail"]
    add_version_models.each do |model|
      ##### get images

      if image_new_version_id.present?
        images = NBD::ImageNewVersionsGenerator.images_query_from_cli_params("id>", image_new_version_id.to_i - 1, "image", model)
      else
        images = NBD::ImageNewVersionsGenerator.images_query_from_cli_params("date>", (Date.current - 1.day).to_s, "image", model)
      end
      
      if images.present?
        images.each do |image|
          ##### get info
          final_url, file_name = NBD::ImageNewVersionsGenerator.image_url(image, "#{model}")

          ##### process and write temp file
          begin
            NBD::ImageNewVersionsGenerator.process_image(final_url, model, model == "article" ? "limit" : "fill", file_name)
          rescue Exception => e
            puts "#{e}"
            puts "get image failed"
            next
          else
            puts "get image success"
          end

          ##### upload and delete temp file
          begin
            NBD::ImageNewVersionsGenerator.upload_file(file_name, image, "#{model}")
          rescue Exception => e
            puts "#{e}"
            next
          else
            puts "upload processed file success"
            redis_client.set("image_new_version_id", image.id)
          end
        end
      end
    end

    Dir.delete("tmp_pics") if Dir.exist?("tmp_pics")

    puts "======generate new versions for new articles done======"
  end
end