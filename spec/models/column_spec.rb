require 'spec_helper'

describe Column do
  it "test all_articles" do
    c1 = Factory.create(:root_column)
    c2 = Factory.create(:children_column, :parent_id => c1.id)
    a = Factory.create(:article)
    c2.articles << a
    c1.all_articles.should == [a]
  end
end


# == Schema Information
#
# Table name: columns
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)     not null
#  parent_id  :integer(4)
#  max_pos    :integer(4)      default(0), not null
#  created_at :datetime
#  updated_at :datetime
#

