require 'spec_helper'

describe "stock_lives/show.html.erb" do
  before(:each) do
    @stock_live = assign(:stock_live, stub_model(StockLive))
  end

  it "renders attributes in <p>" do
    render
  end
end
