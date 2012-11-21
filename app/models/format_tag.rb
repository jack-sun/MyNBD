require 'rack'
module FormatTag
  include Nbd::Application.routes.url_helpers

  def self.included(base)
    base.extend         ClassMethods
    base.class_eval do
      
    end
    base.send :include, InstanceMethods
  end # self.included

  module ClassMethods

  end # ClassMethods

  module InstanceMethods
    def format_tags(content, options={})
      regex = /#([^\/#]+?)#/
      if content =~ regex
        content = content.gsub(regex) do |matched_string|
          name = $~[1]
         "<a href=\"#{Settings.host}/search/community_search?type=weibo&q=#{Rack::Utils.escape(name)}\" class=\"tag_mention\">##{ERB::Util.h(name)}#</a>"
        end
      end
      content
    end
    
    def contain_tags
      regex = /#([^\/#]+?)#/
      matched_strings = []
      content = raw_content
      if content =~ regex
        content = content.gsub(regex) do |s|
          matched_strings << $~[1]
        end
      end
      matched_strings
    end
  end # InstanceMethods

end
