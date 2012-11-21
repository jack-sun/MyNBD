# encoding: utf-8
class FeaturePage < ActiveRecord::Base
  
  set_table_name "features_pages"
  
  belongs_to :feature
  
  #has_many :elements, :dependent => :destroy, :foreign_key => "feature_page_id"
  has_many :elements, :as => :owner, :dependent => :destroy
  
  SECTION_TYPES = ["section_1_a", "section_2_a", "section_2_b", "section_2_c", "section_3_a"]
  TYPES_HASH = {"section_1_a" => "单列", "section_2_a" => "两列，左窄右宽", "section_2_b" => "两列，左宽右窄", "section_2_c" => "两列，左右等宽", "section_3_a" => "三列，等宽"}
  
  def elements_dict
    dict = {}
    self.elements.each do |e|
      dict.merge!(e.id => e)  
    end
  
    dict
  end

  def set_as_default_layout
    text = ElementText.new(:title => '文本内容', :content => {:body => '文本'}.to_json)
    self.elements << text
    
    self.layout = [{:section_code => 'section_2_a',  :elements => [[text.id], []]}].to_json
    self.save
    return self
  end

end
