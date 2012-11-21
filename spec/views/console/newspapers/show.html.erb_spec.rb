require 'spec_helper'

describe "newspapers/show.html.erb" do
  before(:each) do
    @newspaper = assign(:newspaper, stub_model(Newspaper))
  end

  it "renders attributes in <p>" do
    render
  end
end
