module ActionView
  module Helpers
    class DateTimeSelector
        def build_selects_from_types(order)
          select = ''
          order.reverse.each do |type|
            separator = separator(type) unless type == order.first # don't add on last field
            select.insert(0, separator.to_s + send("select_#{type}").to_s + prepend_by_type(type))
          end
          select.html_safe
        end

        def prepend_by_type(type)
          @options["#{type}_prepend".to_sym] || ""
        end

    end
  end
end
