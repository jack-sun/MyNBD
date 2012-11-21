class Touzibao < ActiveRecord::Base
  PUBLISHED = 1
  DRAFT = 0
  TOUZIBAO_INTRODUCE_URL = "http://touzibao.nbd.com.cn"


  has_many :article_touzibaos, :dependent => :destroy
  has_many :articles, :through => :article_touzibaos

  scope :published, where(:status => PUBLISHED)

  belongs_to :staff

  def published?
    self.status == PUBLISHED
  end

  def self.next_t_index_of(t_index)
    time = Time.new(*(t_index.split("-"))).end_of_day
    Touzibao.published.where(["created_at > ?", time]).order("id desc").last.try(:t_index)
  end

  def self.pre_t_index_of(t_index)
    time = Time.new(*(t_index.split("-"))).beginning_of_day
    Touzibao.published.where(["created_at < ?", time]).order("id desc").first.try(:t_index)
  end

  def self.lastest_cases
    Column.find(Column::TOUZIBAO_CASE_COLUMN).articles.published.order("id desc").first
  end

  def next_t_index
    Touzibao.published.where(["id > ?", self.id]).order("id desc").last.try(:t_index)
  end

  def pre_t_index
    Touzibao.published.where(["id < ?", self.id]).order("id desc").first.try(:t_index)
  end

  def pre
    Touzibao.published.where(["id < ?", self.id]).order("id desc").first
  end

  def change_articles_pos(moved_article, target)
    target_article_id = target.is_a?(Integer) ? target : target.id
    positions = ArticleTouzibao.where(:touzibao_id => self.id, :article_id => [moved_article.id, target_article_id]).to_a.group_by(&:article_id)
    return "faild" if positions.count < 2
    moved_positions = positions[moved_article.id].first
    target_positions = positions[target_article_id].first
    Touzibao.transaction do
      if moved_positions.pos > target_positions.pos
        ArticleTouzibao.update_all("pos = pos+1", ["touzibao_id =? and pos between ? and ?", self.id, target_positions.pos, moved_positions.pos - 1])
      else
        ArticleTouzibao.update_all("pos = pos-1", ["touzibao_id =? and pos between ? and ?", self.id, moved_positions.pos + 1, target_positions.pos])
      end
      moved_positions.pos = target_positions.pos
      moved_positions.save!
      self.updated_at = Time.now
      self.save!
      return "success"
    end
    return "faild"
  end
  
end
