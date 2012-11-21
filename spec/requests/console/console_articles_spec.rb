require 'spec_helper'

describe "Console::Articles" do
  describe "GET /console_articles" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get console_articles_path
      response.status.should be(200)
    end
  end
end
