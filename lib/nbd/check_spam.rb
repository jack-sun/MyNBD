#encoding:utf-8
require 'active_support/core_ext/array'
module Nbd
  module CheckSpam
    def self.included(base)
      base.extend         ClassMethods
      base.class_eval do
        before_validation :check_spam_words
        def self.spam_reg
          Regexp.new(::Badkeyword.dict)
        end
      end
      base.send :include, InstanceMethods
    end # self.included

    module ClassMethods
      def check_spam_attr(*attrs)
        options = attrs.extract_options!
        message = options[:message] || "根据相关法律法规和政策，您输入的内容未予接受"
        self.instance_eval <<-END
        def spam_error_message
          "#{message}"
        end
        END
        attrs.each do |attributes|
          self.class_eval <<-END 
          def check_spam_of_#{attributes}_callback
            send("spam?", "#{attributes}")
          end
          END
        end
        s = attrs.map{|x| "check_spam_of_#{x}_callback"}.join(";")
        self.class_eval <<-END
        def check_spam_words
        return true if self.class.spam_reg == //
        #{s}
        end
        END
      end
    end # ClassMethods

    module InstanceMethods
      def spam?(attr)
        value = eval("self.#{attr}")
        return false if value.blank?
        if value.class == [].class
          value = value.join(" ")
        end
        if matched = self.class.spam_reg.match(value)
          self.errors.add(attr, self.class.spam_error_message)
        end
        return true
      end

    end # InstanceMethods

  end
end
