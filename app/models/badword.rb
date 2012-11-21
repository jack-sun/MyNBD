#encoding:utf-8
class Badword < ActiveRecord::Base
  include BadwordHelper
  BAD_KEYWROD_KEY = "badwords_list_key"
  validates_presence_of :value, :message => "敏感词不能为空"
  belongs_to :staff
  def self.keyword_list_key
    BAD_KEYWROD_KEY 
  end
end
