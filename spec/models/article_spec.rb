require 'spec_helper'

describe Article do
  pending "add some examples to (or delete) #{__FILE__}"
end


# == Schema Information
#
# Table name: articles
#
#  id                :integer(4)      not null, primary key
#  title             :string(255)     not null
#  list_title        :string(255)
#  sub_title         :string(255)
#  digest            :string(300)
#  type              :string(40)      not null
#  slug              :string(32)      not null
#  redirect_to       :string(255)
#  ori_author        :string(64)
#  ori_source        :string(64)
#  comment           :string(300)
#  click_count       :integer(4)      default(0)
#  max_child_pos     :integer(4)      default(0), not null
#  allow_comment     :integer(4)      default(1)
#  status            :integer(4)      default(0)
#  is_rollowing_news :integer(4)      default(0)
#  created_at        :datetime
#  updated_at        :datetime
#

