class ArticlesStaff < ActiveRecord::Base
  belongs_to :staff
  belongs_to :article
  belongs_to :article_for_stat, :class_name => "Article", :select => [:id, :click_count], :foreign_key => "article_id"

  def article_stat
    [self.staff_id, self.article_for_stat.try(:click_count) || 0]
  end

  def self.staffs_stats(staff_ids, filter)
    result = Hash.new([0,0])
    where(:staff_id => staff_ids).time_filter(filter).includes(:article_for_stat).map(&:article_stat).group_by{|x| x.first}.each do |k, v|
      result[k] = [v.count, v.sum(&:last)]
    end
    result
  end
end

# == Schema Information
#
# Table name: articles_staffs
#
#  id         :integer(4)      not null, primary key
#  article_id :integer(4)      not null
#  staff_id   :integer(4)      not null
#  created_at :datetime
#  updated_at :datetime
#

