class ArticlesColumnist < ActiveRecord::Base
  belongs_to :article
  belongs_to :columnist


  after_create :update_columnist
  def update_columnist
    c = self.columnist
    c.last_article = self.article
    c.save
  end
end
