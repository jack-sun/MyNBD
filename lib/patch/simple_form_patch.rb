module SimpleForm
  module Inputs
    class Base
      protected

      def disabled?
        options[:disabled].is_a? TrueClass
      end
    end
  end
end
