require File.expand_path('spec/spec_helper')

describe Weibo do
  subject{Factory.create(:ori_weibo)}
  it "test format content" do
    user = Factory.create(:user)
    subject.content.should =~ %r{<a href="/n/jason" class="mention">@jason</a>}
  end

  it "test mentions" do
    user = Factory.create(:user)
    user.cache_notifications.clear
    subject
    user.mentions.first.target.should == subject
    user.cache_notifications[:new_atme_weibos_count].to_i.should == 1
  end

end
__END__
  it "test rt" do
    w = Factory(:rt_weibo)
    
  end

  it "test comment" do
    
  end
end

# == Schema Information
#
# Table name: weibos
#
#  id              :integer(4)      not null, primary key
#  owner_id        :integer(4)      not null
#  owner_type      :string(255)     not null
#  has_tag         :integer(4)      default(0)
#  content         :text            default(""), not null
#  parent_weibo_id :integer(4)      default(0), not null
#  ori_weibo_id    :integer(4)      default(0), not null
#  rt_count        :integer(4)      default(0)
#  reply_count     :integer(4)      default(0)
#  article_id      :integer(4)      default(0)
#  weibo_type      :integer(4)      default(0)
#  content_type    :integer(4)      default(0)
#  created_at      :datetime
#  updated_at      :datetime
#

