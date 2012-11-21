require 'spec_helper'

describe "console_articles/show.html.erb" do
  before(:each) do
    @article = assign(:article, stub_model(Console::Article))
  end

  it "renders attributes in <p>" do
    render
  end
end
