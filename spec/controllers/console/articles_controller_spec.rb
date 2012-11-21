require File.expand_path('spec/spec_helper')

describe Console::ArticlesController do
  let(:staff){Factory.create(:staff)}
  describe "some article filter" do
    it "unpublished" do
      article = Factory.create(:article)
      article.staffs << staff
      get :unpublished, {}, {:staff => staff}
      assigns(:articles).to_a.should == [article]
    end

    it "pubslished" do
      article = Factory.create(:article, :status => Article::PUBLISHED)
      article.staffs << staff
      get :published, {}, {:staff => staff}
      assigns(:articles).to_a.should == [article]
    end

    it "pending" do
      article = Factory.create(:article, :status => Article::PENDING)
      article.staffs << staff
      get :pending, {}, {:staff => staff}
      assigns(:articles).to_a.should == [article]
    end
  end

  describe "some channel filter" do
    it "" do
      
    end
  end
end
