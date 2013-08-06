require 'nbd/utils'
class Jobs::NewspaperJob
  @queue = :newspaper_parse
  def self.perform(file_path, newspaper_id)
    newspaper = Newspaper.where(:id => newspaper_id).first
    return if newspaper.nil?

    # file = File.new(file_path)
    begin
    articles_data = NBD::Utils.parse_daily_news(file_path)
    rescue Exception => e
      WebsiteLog.error2("newspaper error", "filename:#{file_path.split("/").last}  --  newspaper_id:#{newspaper_id}", e)
      Newspaper.get_file_status_hash_key(newspaper_id)["#{file_path.split("/").last}"] = Newspaper::STATUS_PARSE_ERROR
      Rails.logger.debug "------------#{Newspaper.get_file_status_hash_key(newspaper_id)["#{file_path.split("/").last}"]}"
      return 
    end
    return if articles_data.blank?
    current_page = articles_data.first["page"].to_s
    return if newspaper.saved_pages.include?(current_page)
    Newspaper.transaction do
      newspaper.add_articles(articles_data)
      Newspaper.get_file_status_hash_key(newspaper_id)["#{file_path.split("/").last}"] = Newspaper::STATUS_PARSE_SUCCESS
      return
    end
    Newspaper.get_file_status_hash_key(newspaper_id)["#{file_path.split("/").last}"] = Newspaper::STATUS_PARSE_ERROR
    Rails.logger.debug "----------------  parse error ----------------"
  end
end
