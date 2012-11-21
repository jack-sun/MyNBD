#todo
#test parent_weibo's rt_count
#test comment and rt weibo
#refactor the tow method
require File.expand_path('spec/spec_helper')

describe User do
  let(:ori_weibo) {Factory.create(:ori_weibo)}
  let(:new_weibo) {Factory.create(:weibo)}
  subject{Factory.create(:user)}
  it "#rt_weibo" do
    weibo = subject.create_weibo(:content => "aaaa")
    user1 = Factory.create(:user1)
    user1.comment_to_weibo(weibo, :content => "cccc")
    user1.comment_to_weibo(weibo, :content => "ccccccc")
    subject.comment_notifications.each do |x|
      puts x.target
      puts x.target.weibo
    end
  end
  describe "#rt_weibo" do

    it "just rt" do
      weibo_params = {:content => "hihi", :comment_to_parent => "0", :comment_to_ori => "0"}
      expect {
        subject.rt_weibo(ori_weibo, weibo_params)
      }.not_to change{Comment.count}
    end

    it "rt and comment to parent weibo" do
      weibo_params = {:content => "hihi", :comment_to_parent => "1", :comment_to_ori => "0"}
      expect{
        rt_weibo = subject.rt_weibo(ori_weibo, weibo_params)
      }.to change{Comment.count}
      Comment.first.weibo_id.should == ori_weibo.id
    end

    it "rt and comment to parent weibo and ori weibo" do
      weibo_params = {:content => "hihi", :comment_to_parent => "1", :comment_to_ori => "1"}
      rt_weibo = subject.rt_weibo(ori_weibo, :content => "hahah")
      rt_weibo = subject.rt_weibo(rt_weibo, weibo_params)
      Weibo.find(ori_weibo.id).all_comments.count.should == 1
      Weibo.find(ori_weibo.id).comments.count.should == 0
    end

    it "rt and comment to ori weibo" do
      weibo_params = {:content => "hihi", :comment_to_parent => "0", :comment_to_ori => "1"}
      rt_weibo = subject.rt_weibo(ori_weibo, :content => "hahah")
      rt_weibo = subject.rt_weibo(rt_weibo, weibo_params)
      rt_weibo.comments.count.should == 0
      Weibo.find(rt_weibo.ori_weibo_id).comments.count.should == 1
    end
  end

  describe "#comment_to_weibo" do
    it "just comment to parent" do
      comment_params = {:content => "hhh", :rt_weibo => "0", :comment_to_ori_weibo => "0"}
      subject.comment_to_weibo(new_weibo, comment_params)
      new_weibo.reload.comments.count.should == 1
    end

    it "comment to ori weibo" do
      comment_params = {:content => "hhh", :rt_weibo => "0", :comment_to_ori_weibo => "1"}
      subject.comment_to_weibo(new_weibo, comment_params)
      Weibo.find(new_weibo.ori_weibo_id).all_comments.count.should == 1
    end

    it "comment and rt" do
      comment_params = {:content => "hhh", :rt_weibo => "1", :comment_to_ori_weibo => "1"}
      expect {
        subject.comment_to_weibo(new_weibo, comment_params)
      }.to change{Comment.count}
      rt_weibo = Weibo.first
      puts rt_weibo.inspect
      rt_weibo.ori_weibo_id.should == new_weibo.ori_weibo_id
      rt_weibo.parent_weibo_id.should == new_weibo.id
    end

    describe "test comment notification" do
      it "not to the ori weibo" do
        weibo_new = subject.create_weibo(:content => "hihi")
        comment_params = {:content => "hhh", :rt_weibo => "0", :comment_to_ori_weibo => "0"}
        user1 = Factory(:user1)
        comment = user1.comment_to_weibo(weibo_new, comment_params)
        subject.refer_comments.first.should == comment
      end

      it "when the comment owner is the weibo owner" do
        weibo_new = subject.create_weibo(:content => "hihi")
        comment_params = {:content => "hhh", :rt_weibo => "0", :comment_to_ori_weibo => "0"}
        puts subject.id
        comment = subject.comment_to_weibo(weibo_new, comment_params)
        subject.refer_comments.first.should be_blank
      end

      describe "comment to the ori weibo" do
        let(:weibo_new){subject.create_weibo(:content => "hihi")}
        let(:user1){Factory.create(:user1)}
        let(:rt_weibo){user1.rt_weibo(weibo_new, :content => "pp")}
        let(:user2){Factory.create(:user1, :nickname => "hhkhh", :email => "kk@qq.com")}
        it "comment to the ori weibo" do
          comment_params = {:content => "hhh", :rt_weibo => "0", :comment_to_ori_weibo => "1"}
          comment = user2.comment_to_weibo(rt_weibo, comment_params)
          subject.refer_comments.first.should == comment
          user1.refer_comments.first.should == comment
        end

        it "comment to the ori weibo but the rt user is the comment user" do
          comment_params = {:content => "hhh", :rt_weibo => "0", :comment_to_ori_weibo => "1"}
          comment = user1.comment_to_weibo(rt_weibo, comment_params)
          subject.refer_comments.first.should == comment
          user1.refer_comments.should be_blank
        end

        it "comment to the ori weibo but the ori user is the comment user" do
          comment_params = {:content => "hhh", :rt_weibo => "0", :comment_to_ori_weibo => "1"}
          comment = subject.comment_to_weibo(rt_weibo, comment_params)
          user1.refer_comments.first.should == comment
          subject.refer_comments.should be_blank
        end

        it "comment to the ori weibo but the ori user is the rt user" do
          rt_weibo = subject.rt_weibo(weibo_new, :content => "pp")
          comment_params = {:content => "hhh", :rt_weibo => "0", :comment_to_ori_weibo => "1"}
          comment = user1.comment_to_weibo(rt_weibo, comment_params)
          subject.refer_comments.count.should == 1
        end

        it "test cached notifications" do
          subject.refresh_notifications
          rt_weibo = subject.rt_weibo(weibo_new, :content => "pp")
          comment_params = {:content => "hhh", :rt_weibo => "0", :comment_to_ori_weibo => "1"}
          comment = user1.comment_to_weibo(rt_weibo, comment_params)
          subject.cache_notifications[:new_comments_count].to_i.should == 1
        end
      
      end

    end
    
  end
  it "test follow and unfollow" do
    u1 = Factory(:user)
    u2 = Factory(:user1)
    u1.refresh_notifications
    u2.refresh_notifications
    u1.follow(u2)
    #test redis-object
    u1.cache_followings.first.to_i.should == u2.id
    u2.cache_followers.first.to_i.should == u1.id
    u2.cache_notifications[:new_followers_count].to_i.should == 1

    u1.followings.to_a.should == [u2]
    u1.followings_count.should == 1
    u2.followers.to_a.should == [u1]
    u2.followers_count.should == 1

    u1.unfollow(u2)
    #test redis-object
    u2.cache_followers.should be_empty
    u1.cache_followings.should be_empty
    u1.followings.should be_blank
    u1.followings_count.should == 0
    u2.followers.should be_blank
    u2.followers_count.should == 0
  end
end
__END__

  it "test follow and unfollow stocks" do
    u = Factory(:user)
    s = Factory(:stock)
    puts u.stocks
    u.follow_stock(s)
    u.stocks.to_a.should == [s]
    s.followers.to_a.should == [u]
    u.stocks_count.should == 1
    s.followers_count.should == 1

    u.unfollow_stock(s)
    u.stocks.should be_blank
    s.reload
    s.followers.should be_blank
    s.followers_count.should == 0
    u.stocks_count.should == 0
  end

  it "test create weibo and rt weibo" do
    u = Factory(:user)
    w = u.create_plain_text_weibo("hahahahahah")
    u.reload
    w.reload
    u.weibos.to_a.should == [w]

    rt_w = u.rt_weibo(w, :content => "lalalala")
    rt_w.reload
    w.reload
    w.rt_count.should == 1
    u.reload
    u.weibos.to_a.should == [rt_w, w]

    rt_rt_w = u.rt_weibo(rt_w, :content => "wulawula")
    w.reload
    rt_w.reload
    rt_w.rt_count.should == 1
    u.weibos.to_a.sort_by(&:id).should == [w, rt_w, rt_rt_w].sort_by(&:id)
    w.rt_weibos.to_a.sort_by(&:id).should == [rt_w, rt_rt_w].sort_by(&:id)
    w.rt_count.should == 2
  end

  it "test comment and reply to origin weibo" do
    u = Factory(:user)
    w = u.create_plain_text_weibo("hahahahahah")
    c = u.comment_to_weibo(u, "pppppppppppppp")
    w.reload
    w.reply_count.should == 1

    w.comments.to_a.should == [c]
    w.all_comments.to_a.should == [c]

    rt_w = u.rt_weibo(w, :content => "hhhhhhhhhhhhhh")
    c1 = u.comment_to_weibo(rt_w, "ccccccccccc")
    w.reload
    w.all_comments.to_a.should == [c]
    rt_w.all_comments.to_a.should == [c1]

    c2 = u.comment_to_ori_weibo(rt_w, "jjjjjjjjjjjjjjj")
    w.reload
    w.all_comments.to_a.should == [c, c2]
    rt_w.comments.should == [c1, c2]
    w.reply_count.should == 1
  end

  it "test follow_weibos" do
    u1 = Factory(:user)
    u2 = Factory(:user1)
    u2.follow(u1)
    w = u1.create_plain_text_weibo("hhhhhh")
    u2.weibos_following.to_a.should == [w]
  end

  it "test rt_weibo_and comment" do
    content1 = "hhhhhhhhhh"
    content2 = "pppppppppp"
    content3 = "jjjjjjjjjj"
    u = Factory(:user)
    w = u.create_plain_text_weibo(content1)
    w1 = u.rt_weibo(w, {:content => content2})

    lambda do
      w3 = u.rt_weibo_and_comment(w1, {:content => content3}, false, false)
    end.should_not change(Comment, :count)

    w4 = u.rt_weibo_and_comment(w1, {:content => content3}, true, false)
    w1.reload.comments.to_a.should == [Comment.first]
    w.reload.comments.should be_blank
    w.reload.all_comments.should be_blank

    w5 = u.rt_weibo_and_comment(w1, {:content => content3}, true, true)
    w1.reload.comments.should == (c1 = Comment.all)
    w.reload.all_comments.to_a.should == [Comment.last]

    w.reload.comments.should be_blank
    w6 = u.rt_weibo_and_comment(w1, {:content => content3}, false, true)
    w.reload.comments.should == [Comment.last]
    w1.reload.comments.should == c1
  end

  it "test delete weibo" do
    u = Factory(:user)
    w = u.create_plain_text_weibo("hahahahahah")
    u1 = Factory(:user1)
    puts u.weibos.class
    lambda do
      u1.delete_weibo(w)
    end.should_not change(Weibo, :count)
    lambda do
      u.delete_weibo(w)
    end.should change(Weibo,:count).by(-1)
  end

end

# == Schema Information
#
# Table name: users
#
#  id                     :integer(4)      not null, primary key
#  email                  :string(64)      not null
#  nickname               :string(64)      not null
#  hashed_password        :string(64)      not null
#  salt                   :string(64)      not null
#  reg_from               :integer(4)      default(0)
#  user_type              :integer(4)      default(1)
#  auth_token             :string(32)      not null
#  status                 :integer(4)      default(0), not null
#  password_reset_token   :string(32)
#  password_reset_sent_at :datetime
#  activate_token         :string(32)
#  activate_sent_at       :datetime
#  followings_count       :integer(4)      default(0)
#  followers_count        :integer(4)      default(0)
#  stocks_count           :integer(4)      default(0)
#  weibos_count           :integer(4)      default(0)
#  created_at             :datetime
#  updated_at             :datetime
#

