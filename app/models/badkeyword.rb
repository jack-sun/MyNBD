#encoding: utf-8
class Badkeyword < ActiveRecord::Base
  BAD_KEYWROD_KEY = "badkeywords_list_key"
  include BadwordHelper
  
  set_table_name "badkeywords"
  
  validates_presence_of :value, :message => "敏感词不能为空"
  
  def self.keyword_list_key
    BAD_KEYWROD_KEY 
  end
end
