module MentionTarget

  def self.included(base)
    base.extend         ClassMethods
    base.class_eval do
      has_many :mentions, :as => "target", :dependent => :destroy
      include FormatTag
      after_create :create_mentions
    end
    base.send :include, InstanceMethods
  end # self.included

  module ClassMethods
    
  end # ClassMethods

  module InstanceMethods
   
  	# http://edgeguides.rubyonrails.org/security.html#sql-injection
    class Helper
    	include Singleton
      	include ActionView::Helpers::TextHelper
      	include ActionView::Helpers::SanitizeHelper
      	include ActionView::Helpers::TagHelper
        include ActionView::Helpers::UrlHelper
    end
    def helper
      	Helper.instance    
    end
    
    def content(opts = {})
        show_content = helper.sanitize(self.formatted_content(opts), :tags => %w(a img br), :attributes => %w(href title class src))
        show_content = helper.auto_link(show_content) unless show_content.index("img")
        
        # http://apidock.com/rails/ActionView/Helpers/TextHelper/simple_format
        show_content = show_content.gsub(/\r*\n/,"<br/>") unless opts[:strip_break] #.gsub(/\r\n?/, "\n").gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')
        
        show_content.html_safe
    end

    def raw_content
      read_attribute(:content)
    end

    def raw_content=(content)
      write_attribute(:content, content)
    end

    def formatted_content(opts={})
      return self.raw_content unless self.raw_content
      
      raw_content = self.raw_content
      raw_content = helper.truncate(self.raw_content, :length => opts[:length]) if opts[:length].present?
      
      mentioned_content = self.format_mentions(raw_content, opts)
      format_tags(mentioned_content, opts)
    end 

    def format_mentions(text, opts = {})
      regex = /@(([^\s])+)(?=\s)/
      if text =~ regex
        text = text.gsub(regex) do |matched_string|
          name = $~[1]
         "<a href=\"#{Settings.weibo_host}/n/#{name}\" class=\"mention\">@#{ERB::Util.h(name)}</a>"
        end
      end
      text
    end

    def mentioned_users
      if self.persisted?
        create_mentions if self.mentions.empty?
        self.mentions.includes(:user).map{ |mention| mention.user }
      else
        mentioned_people_from_string
      end
    end

    def create_mentions
      mentioned_people_from_string.each do |user|
        self.mentions.create(:user => user)
      end
    end

    def mentions?(user)
      mentioned_users.include? user
    end

    def mentioned_people_from_string
      #regex = /@\{([^;]+); ([^\}]+)\}/
      regex = /@(([^\s])+)(?=\s)/
      nick_names = self.raw_content.scan(regex).map do |match|
        match.first
      end.uniq
      nick_names.empty? ? [] : User.where(:nickname => nick_names)
    end
  end # InstanceMethods

end
