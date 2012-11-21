require 'spec_helper'

describe SearchController do

  describe "GET 'article_search'" do
    it "should be successful" do
      get 'article_search'
      response.should be_success
    end
  end

end
