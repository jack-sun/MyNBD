#encoding:utf-8
class Page < ActiveRecord::Base
  belongs_to :article
  belongs_to :image, :dependent => :destroy
  #include Nbd::CheckSpam

  script_reg = /<script .*?>.*?<\/script>/

  #check_spam_attr "content"

  accepts_nested_attributes_for :image, :reject_if => lambda { |a| a[:article].blank?}
  before_save :sanitize_tag
  def sanitize_tag
    self.content = helper.sanitize(self.content, :tags => %w(a b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup p img embed  object param), :attributes => %W(id class style name src href target title alt width height value type wmode classic codebase)).gsub(/<p>(\u0020|\u3000)*/,"<p>")
  end
  #before_save :touch_article
  #def touch_article
    #self.article.updated_at = Time.now
    #self.article.save
  #end

  #before_save :touch_article
  
  
  def is_first_page?
    p_index.to_i == 1
  end
  
  private
  def helper
    Helper.instance    
  end
end
class Helper
  include Singleton
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TagHelper
end


# == Schema Information
#
# Table name: pages
#
#  id         :integer(4)      not null, primary key
#  article_id :integer(4)      not null
#  content    :text            default(""), not null
#  video      :string(255)
#  index      :integer(4)      default(1)
#  created_at :datetime
#  updated_at :datetime
#

