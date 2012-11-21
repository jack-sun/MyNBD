# encoding: utf-8
class Element < ActiveRecord::Base
  
  set_table_name "elements"
  
  #belongs_to :feature_page, :class_name => "FeaturePage", :foreign_key => "feature_page_id"
  belongs_to :owner, :polymorphic => :true
  
  
  ELEMENT_NAME_MAP = [{"text" => "文本内容"}, {"link" => "链接列表"},  
  {"article" => "动态文章列表"}, {"feature" => "手动文章列表"}, {"image" => "图文并茂"}, {"image_cell" => "图片格子"}, {"cweibo" => "微博聚合"},
  {"poll" => "投票"}, {"html" => "HTML代码块"}, {"title" => "标题"}]
  
  ELEMENT_TYPES = ELEMENT_NAME_MAP.map{|e| e.keys.first}
  ELEMENT_TYPE_HASH = ELEMENT_NAME_MAP.inject({}){|x, y| x[y.first[0]]=y.first[1];x;}

  after_destroy :destroy_image
  #after_destroy :destroy_poll
  def destroy_image
    if self.content =~ /source/
      image_id=((t = JSON.parse(self.content)["body"]) && t["source"])
      Image.find(image_id).destroy if image_id
    end
  rescue Exception
  end

  def destroy_poll
    if self.type == "ElementPoll"
      poll_id=((t = JSON.parse(self.content)["body"]))
      Poll.where(:id => poll_id).first.try(:destroy)
    end
  end

  def element_type
    ELEMENT_TYPE_HASH[(self.type[7..-1]).downcase]
  end

  def element_title
    "#{self.title}(#{self.element_type})"
  end
end
