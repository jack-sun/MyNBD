require 'spec_helper'

describe "console_images/show.html.erb" do
  before(:each) do
    @image = assign(:image, stub_model(Console::Image))
  end

  it "renders attributes in <p>" do
    render
  end
end
