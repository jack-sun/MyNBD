module UrlHelper
end

module ActionDispatch
  module Routing
    class RouteSet
      class NamedRouteCollection
        private
          def define_hash_access(route, name, kind, options)
            selector = hash_access_name(name, kind)
            if kind == :url && route.requirements[:subdomain]
              options.merge!({:subdomain => SUBDOMSIN_EXP[route.requirements[:subdomain]]})
            end

            # We use module_eval to avoid leaks
            @module.module_eval <<-END_EVAL, __FILE__, __LINE__ + 1
              def #{selector}(options = nil)                                      # def hash_for_users_url(options = nil)
                options ? #{options.inspect}.merge(options) : #{options.inspect}  #   options ? {:only_path=>false}.merge(options) : {:only_path=>false}
              end                                                                 # end
              protected :#{selector}                                              # protected :hash_for_users_url
            END_EVAL
            helpers << selector
          end
      end
    end
  end
end

ActionDispatch::Routing.send(:include, UrlHelper)
