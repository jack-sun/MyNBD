require 'spec_helper'

describe "newspapers/index.html.erb" do
  before(:each) do
    assign(:newspapers, [
      stub_model(Newspaper),
      stub_model(Newspaper)
    ])
  end

  it "renders a list of newspapers" do
    render
  end
end
