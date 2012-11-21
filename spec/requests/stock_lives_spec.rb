require 'spec_helper'

describe "StockLives" do
  describe "GET /stock_lives" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get stock_lives_path
      response.status.should be(200)
    end
  end
end
