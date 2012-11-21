class ArticlesChildren < ActiveRecord::Base
  belongs_to :article
  belongs_to :children, :class_name => "Article"

  scope :desc, order("id desc")

  def children_title
    return read_attribute(:children_title) if self.new_record?
    if read_attribute(:children_title).blank?
      children.try(:title)
    else
      read_attribute(:children_title)
    end
  end

  def children_url
    return read_attribute(:children_url) if self.new_record?
    if read_attribute(:children_url).blank?
      children.nil? ? "" : article_url(children)
    else
      read_attribute(:children_url)
    end
    
  end
  private

  def article_url(article, html_suffix = true)
    if article.redirect_to.present?
      article.redirect_to
    else
      url = "#{Settings.host}/articles/#{article.created_at.strftime("%Y-%m-%d")}/#{article.id}"
      url += ".html" if html_suffix
      url
    end
  end
end


# == Schema Information
#
# Table name: articles_children
#
#  id          :integer(4)      not null, primary key
#  article_id  :integer(4)      not null
#  children_id :integer(4)      not null
#  pos         :integer(4)      default(1), not null
#  created_at  :datetime
#  updated_at  :datetime
#

