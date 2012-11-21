require 'rss/utils'
require 'rss/xml'

module RSS
  module Utils
    def html_escape(s) s.to_s.gsub(/script/, "").gsub(/&amp;/, "&").gsub(/&quot;/, "\"").gsub(/&gt;/, ">").gsub(/&lt;/, "<").gsub(/&ldquo;/, "\"").gsub(/&rdquo;/, "\"") end
  end
end

