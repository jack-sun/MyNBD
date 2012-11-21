require 'spec_helper'

describe "stock_lives/edit.html.erb" do
  before(:each) do
    @stock_live = assign(:stock_live, stub_model(StockLive))
  end

  it "renders the edit stock_live form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => stock_lives_path(@stock_live), :method => "post" do
    end
  end
end
