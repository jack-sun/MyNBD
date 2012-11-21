module ::RedisStore
  module Cache
      # Delete objects for matched keys.
      #
      # Example:
      #   cache.del_matched "rab*"
    module Rails3
      def delete_matched(matcher, options = nil)
        options = merged_options(options)
        instrument(:delete_matched, matcher.inspect) do
          matcher = key_matcher(matcher, options)
          begin
            !(keys = @data.keys(matcher)).empty? && keys.each_slice(10000){|k| @data.del(*k) }
            Rails.logger.info "--------------expire #{keys.count} fragment ---------------"
          rescue Errno::ECONNREFUSED => e
            false
          end
        end
      end
    end
  end
end
