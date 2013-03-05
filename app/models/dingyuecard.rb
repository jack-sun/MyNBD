# encoding: utf-8
class Dingyuecard < ActiveRecord::Base
  establish_connection "nbdcms"
  set_table_name "cms_content4"
  set_primary_key "tid"

end
