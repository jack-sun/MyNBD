# encoding: utf-8
require 'pathname'
require 'pp'
class WebsiteLog < ActiveRecord::Base
  
  set_table_name "website_logs"
  
  SRC_NBD = 0
  
  LEVEL_DEBUG = 0
  LEVEL_TIMEOUT = 1
  LEVEL_ERROR = 2
  
  class << self
    
    def timeout(controller, request, elapsed)
      title = "#{request.request_uri}, #{elapsed} sec"
      log(SRC_NBD, LEVEL_TIMEOUT, request, title, '', controller)
    end
    
    def error(controller, request, exception)
      title = "#{request.env['SERVER_NAME']}#{request.url}"
      log(SRC_NBD, LEVEL_ERROR, request, title, '', controller, exception)
    end

    def error2(title, message, exception)
      log2(SRC_NBD, LEVEL_ERROR, title, message, exception)
    end
    
    def log(src, level, request, title, body, controller = nil, exception = nil)
      body << "<hr>" if !body.blank?
      hostname = request.env['SERVER_ADDR']
      body << "<pre><span style='color:#00FFFF;'>Host: #{hostname}</span></pre>"
      body << "<pre>#{self.inspect_request_env(request.env)}</pre>"
      body << "<hr><pre>#{controller.logger.last_log_message}</pre>" if controller
      body << "<hr><pre>Error Name:#{exception}</pre>"
      body << "<hr><pre>#{exception.backtrace.join('<br/>')}</pre>" if exception
      WebsiteLog.create({
        :src => src,
        :level => level,
        :url => "#{request.env['SERVER_NAME']}#{request.url}",
        :title => title,
        :message => body,
        :created_at => Time.now})
    end
    
    def log2(src, level, title, message, exception = nil, request = nil, controller = nil)
      if message && !message.kind_of?(String)
        message = '<pre>' + ERB::Util.h(message.pretty_inspect) + '</pre>'
      end
      message << "<hr/>" unless message.blank?
      message << "<pre><span style='color:#00FFFF;'>Host: #{`hostname`}</span></pre>"
      message << "exception: <br/><pre>#{ERB::Util.h(exception.pretty_inspect)}\n#{ERB::Util.h(exception.backtrace.pretty_inspect)}</pre>" if exception
      message << "<pre>#{self.inspect_request_env(request.env)}</pre>" if request
      message << "<hr><pre>#{controller.logger.last_log_message}</pre>" if controller
      message << "<hr><pre>Error Name:#{exception.inspect}</pre>"
      
      self.create({
        :src => src,
        :level => level,
        :url => request ? request.url : '',
        :title => title,
        :message => message,
        :created_at => Time.now})
    end

    # request.env now contains a lot of objects. simply request.env.pretty_inspect is too expensive
    def inspect_request_env(env)
      h = {}
      env.each_key do |key|
        if key.upcase == key
          h[key] = env[key]
        end
      end
      h.pretty_inspect
    end
    
    def sanitize_backtrace(trace)
      re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
      trace.map do |line|
        Pathname.new(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s
      end
    end
    
    def rails_root
      @rails_root ||= Pathname.new(Rails.root).cleanpath.to_s
    end
    
    
  end
  
end
