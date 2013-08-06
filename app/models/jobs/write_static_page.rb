require 'fileutils'
require 'nbd/remote_ssh'
include NBD::RemoteSsh
class Jobs::WriteStaticPage
  @queue = :article_static_page
  def self.perform(content, path, remote = Settings.push_static_pages_to_remote)
    unless remote
      FileUtils.makedirs(File.dirname(path))
      File.open(path, "wb+"){|f| f.write(content) }
    else
      host = StaticPage::Setting.instance.setting["remote"]["host"]
      user = StaticPage::Setting.instance.setting["remote"]["user"]
      run_command(user, host, "mkdir -p #{File.dirname(path)}")
      write_body(user, host, content, path)
    end
  end
end
