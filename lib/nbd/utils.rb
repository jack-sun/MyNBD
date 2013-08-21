# encoding: utf-8
# Vincent Tsao, Chengdu, 07/26/2011

require 'digest/md5'
require 'open-uri'

module NBD
  module Utils
   
   	# 
   	# rails c
   	# require 'nbd/utils'
   	# p NBD::Utils.parse_daily_news(RAILS_ROOT+'/doc/daily_news_sample.trs')
   	# 
   	def self.parse_daily_news(file)
      # Rails.logger.debug "============= file: #{file.inspect}"

        str_array = ["r:gb2312", "r:gbk"]
        str = str_array.pop

        File.open("#{Rails.root.to_s}/log/newspaper_parse.log", 'a') do |f|
          f.puts "============= file: #{file.inspect}"
          f.puts "============= #{str}"
        end

        begin
          items = []
          item = {}
          open("#{::Settings.local_image_host}#{file}", str) do |f|
          # File.open(file, str) do |f|
            
            f.gets #remove first line <REC>
            
            # items = []
            # item = {}
            item["content"] = []
            
            while (line = f.gets)
              
              line = line.sub(/\r\n/, '')
              
              if	line == '<REC>'
                  items << item
                  item = {}
                  item["content"] = []
              
              else
                  line.encode("utf-8") =~ /^<(.+)>=(.*)/
                  case $1
                      when '标题'
                          item['title'] = $2
                      when '作者'
                          author_string = $2.encode("utf-8").gsub(/\u3000/, ' ')
                          item['ori_author'] = author_string
                      when '日期'
                          item['date'] = Time.parse($2)
                      when '版次'
                          item['page'] = $2
                      when '版名'
                          item['section'] = $2
                      when '栏目'
                          item['column'] = $2
                      when '正文'
                          #item['content'] = $2
                      when '引题'
                          item['list_title'] = $2.nil? ? nil : $2.encode("utf-8").gsub(/\u3000/, ' ').strip
                      when '副题'
                          item['sub_title'] = $2
                      when '图像'
                          item['image_url'] = $2
                      when '图片作者'
                          item['image_author'] = $2
                      when '图片说明'
                          item['image_description'] = $2
                      when '稿件来源'
                          item['ori_source'] = $2
                      else #正文续
                          # 全角空格转半角空格后，进行strip
                          p = line.encode("utf-8").gsub(/\u3000/, ' ').strip
                          item['content'] << p unless p.blank?
                  end
              end 
            end #end while
            items << item
            
            items.each do |item|
              # Remove useless content line
              if item['content'].join(" ").scan("如需转载请与《每日经济新闻》报社联系").present?
                content_line_number = item['content'].size
                copyright_line_number = 5
                item['content'].slice!(content_line_number-copyright_line_number, content_line_number)
              end
              
              item['copyright'] = Article::COPYRIGHT_YES
            end.reject!{|item| item['content'].blank?}
            
            # return items
          end
          return items
        rescue Encoding::InvalidByteSequenceError => e
          str = str_array.pop
          raise StandardError  if str.nil?
          # Rails.logger.info "Ecoding Error #{str}"
          File.open("#{Rails.root.to_s}/log/newspaper_parse.log", 'a') do |f|
            f.puts "Ecoding Error #{str}"
          end
          retry
        rescue ArgumentError => e
          str = str_array.pop
          raise StandardError  if str.nil?
          # Rails.logger.info "Argument Error #{str}"
          File.open("#{Rails.root.to_s}/log/newspaper_parse.log", 'a') do |f|
            f.puts "Argument Error #{str}"
          end
          retry
        end
   	end
   
   
    def self.to_md5(str)
      Digest::MD5.hexdigest(str)
    end
    
    # Sorts an Array ordered by another Array with mapping rule specified by param options or a block
    # options either :key => key or :method => :method_name
    # block {|ele| ..} takes an element in to_sort and returns correspoding element in order_by_array
    # e.g. 
    #   sort_by_array([{:name => 'arrix'}, {:name => 'tommy'}], %w{tommy arrix}, :key => 'name')
    #   sort_by_array(User.find(:all, :conditions => ['id IN (?)', ids]), ids, :method => :id)
    #   sort_by_array(User.find(:all, :conditions => ['id IN (?)', ids]), ids) {|v| v.id}
    #
    def self.sort_by_array(to_sort, order_by_array, options)
      h = {}
      order_by_array = [] if !order_by_array
      to_sort.each do |v|
        h[
          case 
          when options[:key]
            v[options[:key]]
          when options[:method]
            v.send(options[:method])
          when block_given?
            yield v
          end
        ] = v
      end

      r = []
      order_by_array.each do |v|
        r << h[v]
      end

      r.compact
    end


    ##
    # CAUTION: DO NOT use this to parse the tags field from db, use split(',')
    # tag input text to tag array
    # tag input is comma/space separated. content between "" is treated as a single tag
    # tag processing rules
    # replace \ or / with _
    # strip leading and trailing spaces
    # replace whitespace with space
    #
    # options
    #   :sort       if true, the returned array will be sorted alphabetically. defaults to false
    #   :downcase   if true, all tags will be in lowercase. defaults to false
    #   :from_url   if true, the special chars will be replaced. defaults to false
    #   :unique     if true, the uniq is case insensetive. e.g. ["a", "A"] -> ["a"]. default is true
    #
    #    puts(NBD::Utils.parse_tags('a b c') == ['a', 'b', 'c'])
    #    puts(NBD::Utils.parse_tags('a,b,c') == ['a', 'b', 'c'])
    #    puts(NBD::Utils.parse_tags('a b,c') == ['a', 'b', 'c'])
    #
    #    puts(NBD::Utils.parse_tags('"a b" c') == ['a b', 'c'])
    #    puts(NBD::Utils.parse_tags('"a b c') == ['a b c'])
    #    puts(NBD::Utils.parse_tags('a "b,c"') == ['a', 'b c'])
    def self.parse_tags(str_tags, options = {:unique=>true})

      return [] if str_tags.blank? # add by Vincent @ 2009-07-15

      if options[:from_url]
        str_tags = str_tags.gsub(/\+/, ' ').strip
        if (str_tags=~/(\w)\s\s/i) != nil
          str_tags = str_tags.gsub(/\w\s\s/i, "#{$1}++")
        end
        if (str_tags=~/(\w)%2B%2B/i) != nil
          str_tags = str_tags.gsub(/\w%2B%2B/i, "#{$1}++")
        end
      end


      stack = []
      tags = []
      begin_delimiter = false
      
      clear_stack = lambda do 
        if stack.length > 0
          tags.push(stack.join(''))
          stack.clear
        end
      end
      
      str_tags.each_char do |c|
        if c == '"'
          if !begin_delimiter
            begin_delimiter = true
          else
            begin_delimiter = false
            clear_stack.call
          end
        else
          if begin_delimiter
            stack.push(c)
          else
            if /\s/ =~ c || c == ','
              clear_stack.call
            else
              stack.push(c)
            end
          end
        end
        
      end
      
      clear_stack.call

      #remove blank items, strip and secure the rest
      tags = tags.select { |t| !t.blank? }.map { |t| 
        t = self.secure_tag(t)
        options[:downcase] ? t.downcase : t
      }.uniq
      
      tags.sort if options[:sort]

      # case insensetive uniq.
      tags = uniq_tags(tags) if options[:unique]
      
      # do not mess with no_tag
      #      tags.delete('no_tag')
      #      return tags.empty? ? ['no_tag'] : tags
      tags
    end

    # case insensetive uniq.
    # e.g. ["hello", "Hello"] -> ["Hello"]
    def self.uniq_tags(tags)
      downcased = []
      tags = tags.inject([]) { |result,h|
        unless downcased.include?(h.downcase);
          result << h
          downcased << h.downcase
        else
          tag = result.select{|t|t.casecmp(h)==0}[0]
          result.delete(tag)
          result << h
        end
        result
      }
    end

    ##
    # quotes a single tag
    #
    #  puts(NBD::Utils.quote_tag("a") == "a")
    #  puts(NBD::Utils.quote_tag("a b") == "\"a b\"")
    #  puts(NBD::Utils.quote_tag("a,b") == "\"a,b\"")
    #  puts(NBD::Utils.quote_tag("\"a\"") == "'a'")
    #  puts(NBD::Utils.quote_tag("a") == "a")
    def self.quote_tag(tag)
      # " => '
      # continues white spaces => one space
      tag = tag.gsub('"', "'").gsub(/\s+/, ' ').strip
      
      # wrap with "" if tag contains delimiter
      tag = "\"#{tag}\""  if tag =~ /\s+|,/
      tag
    end
    
    def self.secure_tag(tag)
      tag.strip.gsub(",", " ").gsub(/\s+/, ' ').gsub(/[\\\/]/, '_')
    end

    ##
    # tag array => string
    def self.unparse_tags(tag_array, join_by = ',')
      tag_array.map { |t| quote_tag(secure_tag(t)) }.join(join_by)
    end
    
    
    #parse tags for search
    def self.parse_search_tags(str_tags)

      return [] if str_tags.blank?

      stack = []
      tags = []
      begin_delimiter = false
      
      clear_stack = lambda do 
        if stack.length > 0
          tags.push(stack.join(''))
          stack.clear
        end
      end
      
      str_tags.each_char do |c|
        if c == '"'
          if !begin_delimiter
            begin_delimiter = true
          else
            begin_delimiter = false
            clear_stack.call
          end
        else
          if begin_delimiter
            stack.push(c)
          else
            if /\s/ =~ c || c == ','
              clear_stack.call
            else
              stack.push(c)
            end
          end
        end
        
      end
      
      clear_stack.call

      #remove blank items, strip and secure the rest
      tags = tags.select { |t| !t.blank? }.map { |t| 
        t = self.secure_tag(t)
      }

      # case insensetive uniq.
      downcased = []
      tags = tags.inject([]) { |result,h|
        unless downcased.include?(h.downcase) && !["NOT","AND","OR"].include?(h);
          result << h
          downcased << h.downcase
        else
          tag = result.select{|t|t.casecmp(h)==0}[0]
          result.delete(tag)
          result << h
        end
        result
      }     
     
      tags
    end

  end
end
