module ActionView
module Helpers
  class InstanceTag
    def to_grouped_collection_select_tag(collection, group_method, group_label_method, option_key_method, option_value_method, options, html_options)
      html_options = html_options.stringify_keys
      add_default_name_and_id(html_options)
      value = value(object)
      selected_value = options.has_key?(:selected) ? options : value
      content_tag(
        "select", add_options(option_groups_from_collection_for_select(collection, group_method, group_label_method, option_key_method, option_value_method, selected_value), options, value), html_options
      )
    end
  end
end
end
