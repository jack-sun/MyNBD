require 'spec_helper'

describe ArticlesChildren do
  pending "add some examples to (or delete) #{__FILE__}"
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

