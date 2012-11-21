require 'spec_helper'

describe "newspapers/new.html.erb" do
  before(:each) do
    assign(:newspaper, stub_model(Newspaper).as_new_record)
  end

  it "renders new newspaper form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => newspapers_path, :method => "post" do
    end
  end
end
