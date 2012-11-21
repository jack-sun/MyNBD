# Add by Vincent 2011-12-01 (Chengdu). Copy From Ken W. (Diigo Inc) 2008/03/20

module ActiveSupport
  class BufferedLogger

    alias :old_add :add
    attr_accessor :last_log_message

    def add(severity, message = nil, progname = nil, &block)
    	msg = old_add(severity, message, progname, &block)
    	@last_log_message ||= ''
    	@last_log_message = '' if @last_log_message.size > 52100 # 50KB
    	@last_log_message << "[#{Time.now.strftime("%H:%M:%S")}]#{msg}"
      msg
    end

  end
end

