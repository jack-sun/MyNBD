#encoding:utf-8
class Notice < ActiveRecord::Base
  
  DRAFT = 0
  PUBLISHED = 1
  BANNDED = 2
  STATUS = {PUBLISHED => "已发布", DRAFT => "草稿", BANNDED => "屏蔽"}
  
  belongs_to :staff
  
end
