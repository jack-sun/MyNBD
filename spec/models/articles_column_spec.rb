require 'spec_helper'

describe ArticlesColumn do
  pending "add some examples to (or delete) #{__FILE__}"
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

