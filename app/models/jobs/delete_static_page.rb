require 'static_page/util'
include StaticPage::Util
class Jobs::DeleteStaticPage
  @queue = :article_fragment_static_page 
  def self.perform(article_id, created_at, remote = Settings.push_static_pages_to_remote)
    subdomains = StaticPage::Setting.instance.setting["article_detail"]["subdomains"]
    host = StaticPage::Setting.instance.setting["remote"]["host"]
    user = StaticPage::Setting.instance.setting["remote"]["user"]
    subdomains.each do |subdomain|
      file_path = get_static_article_path(subdomain, article_id, created_at, 1, true)
      unless remote
          Dir.glob("#{file_path}*").each { |file| File.delete(file) }
      else
        command = "find #{File.dirname(file_path)} -name \"#{article_id}*.html\" -exec rm -f {} \\;"
        run_command(user, host, command)
      end
    end
  end
end
