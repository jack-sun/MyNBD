require 'spec_helper'

describe "console_images/index.html.erb" do
  before(:each) do
    assign(:console_images, [
      stub_model(Console::Image),
      stub_model(Console::Image)
    ])
  end

  it "renders a list of console_images" do
    render
  end
end
