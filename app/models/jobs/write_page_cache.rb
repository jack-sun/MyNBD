require 'fileutils'
class Jobs::WritePageCache
  @queue = :wirte_page_cache_file 
  def self.perform(content, path)
    FileUtils.makedirs(File.dirname(path))
    File.open(path, "wb+"){|f| f.write(content) }
  end
end
