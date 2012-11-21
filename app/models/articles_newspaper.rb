class ArticlesNewspaper < ActiveRecord::Base
  belongs_to :article
  belongs_to :newspaper

  belongs_to :article_for_stat, :class_name => "Article", :select => [:id, :click_count], :foreign_key => "article_id"

  def article_stat
    [self.newspaper_id, self.article_for_stat.try(:click_count) || 0]
  end

  def self.newspapers_stats(n_ids, filter)
    result = Hash.new([0,0])
    where(:newspaper_id => n_ids).time_filter(filter).includes(:article_for_stat).map(&:article_stat).group_by{|x| x.first}.each do |k, v|
      result[k] = [v.count, v.sum(&:last)]
    end
    result
  end
end
