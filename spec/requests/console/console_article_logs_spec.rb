require 'spec_helper'

describe "Console::ArticleLogs" do
  describe "GET /console_article_logs" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get console_article_logs_path
      response.status.should be(200)
    end
  end
end
