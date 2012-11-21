require 'spec_helper'

describe Page do
  pending "add some examples to (or delete) #{__FILE__}"
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

