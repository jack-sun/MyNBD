require 'spec_helper'

describe "newspapers/edit.html.erb" do
  before(:each) do
    @newspaper = assign(:newspaper, stub_model(Newspaper))
  end

  it "renders the edit newspaper form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => newspapers_path(@newspaper), :method => "post" do
    end
  end
end
