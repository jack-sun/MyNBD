require 'spec_helper'

describe "console_articles/edit.html.erb" do
  before(:each) do
    @article = assign(:article, stub_model(Console::Article))
  end

  it "renders the edit article form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => console_articles_path(@article), :method => "post" do
    end
  end
end
