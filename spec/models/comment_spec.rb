require File.expand_path('spec/spec_helper')

describe Weibo do
  let(:user){Factory.create(:user)}
  subject{Factory.create(:comment, :content => "@jason hahahah", :user_id => user.id)}
  it "test format content" do
    subject.content.should =~ %r{<a href="/n/jason" class="mention">@jason</a>}
  end

  it "test mentions" do
    user.cache_notifications.clear
    subject
    user.mentions.comments.first.target.should == subject
    user.cache_notifications[:new_atme_comments_count].to_i.should == 1
  end

end

# == Schema Information
#
# Table name: comments
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)      not null
#  weibo_id     :integer(4)      not null
#  ori_weibo_id :integer(4)      not null
#  content      :text            default(""), not null
#  created_at   :datetime
#  updated_at   :datetime
#

