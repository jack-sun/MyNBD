require 'spec_helper'

describe "console_articles/index.html.erb" do
  before(:each) do
    assign(:console_articles, [
      stub_model(Console::Article),
      stub_model(Console::Article)
    ])
  end

  it "renders a list of console_articles" do
    render
  end
end
