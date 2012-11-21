require 'spec_helper'

describe "stock_lives/index.html.erb" do
  before(:each) do
    assign(:stock_lives, [
      stub_model(StockLive),
      stub_model(StockLive)
    ])
  end

  it "renders a list of stock_lives" do
    render
  end
end
