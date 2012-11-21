require 'spec_helper'

describe Console::SearchController do

  describe "GET 'article_search'" do
    it "should be successful" do
      get 'article_search'
      response.should be_success
    end
  end

  describe "GET 'weibo_search'" do
    it "should be successful" do
      get 'weibo_search'
      response.should be_success
    end
  end

  describe "GET 'user_search'" do
    it "should be successful" do
      get 'user_search'
      response.should be_success
    end
  end

end
