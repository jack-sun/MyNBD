require 'spec_helper'

describe "stock_lives/new.html.erb" do
  before(:each) do
    assign(:stock_live, stub_model(StockLive).as_new_record)
  end

  it "renders new stock_live form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => stock_lives_path, :method => "post" do
    end
  end
end
