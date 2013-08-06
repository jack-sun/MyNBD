class ArticlesColumn < ActiveRecord::Base
  # include ApplicationHelper
  # include Cells::Rails::ActionController
  # include Rails.application.routes.url_helpers # brings ActionDispatch::Routing::UrlFor
  # include ActionView::Helpers::TagHelper

  paginates_per Settings.count_per_page
  belongs_to :article
  belongs_to :column
  belongs_to :column_for_stat, :class_name => "Column", :select => [:id,:parent_id], :foreign_key => "column_id"
  belongs_to :article_for_stat, :class_name => "Article", :select => [:id, :click_count], :foreign_key => "article_id"


  scope :published, where(:status => Article::PUBLISHED)

  STATIC_RESOURCES = {4 => :image_news, 8 => :focus_articles, 5 => :featured_articles, 100 => :nbd_weekly_comment}

  STATIC_COLUMN = STATIC_RESOURCES.keys.concat Column::FEATURE_COLUMN_HASH.values

  def article_stat
    [self.column_id, self.article_for_stat.try(:click_count) || 0]
  end

  def channel_article_stat
    [self.column_for_stat.parent_id, self.article_for_stat.try(:click_count)||0]
  end

  def self.columns_stats(column_ids, filter)
    result = Hash.new([0,0])
    where(:column_id => column_ids).time_filter(filter).includes([:article_for_stat]).map(&:article_stat).group_by{|x| x.first}.each do |k, v|
      result[k] = [v.count, v.sum(&:last)]
    end
    result
  end

  def self.channel_stats(filter)
    result = Hash.new([0,0])

    time_filter(filter).includes([:article_for_stat, :column_for_stat]).map(&:channel_article_stat).group_by{|x| x.first}.each do |k, v|
      result[k] = [v.count, v.sum(&:last)]
    end
    result
  end

end


# == Schema Information
#
# Table name: articles_columns
#
#  id         :integer(4)      not null, primary key
#  article_id :integer(4)      not null
#  column_id  :integer(4)      not null
#  pos        :integer(4)      default(1), not null
#  created_at :datetime
#  updated_at :datetime
#

