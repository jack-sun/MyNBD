class TagsWeibo < ActiveRecord::Base
  belongs_to :tag
  belongs_to :weibo
end

# == Schema Information
#
# Table name: tags_weibos
#
#  id         :integer(4)      not null, primary key
#  tag_id     :integer(4)      not null
#  weibo_id   :integer(4)      not null
#  created_at :datetime
#  updated_at :datetime
#

