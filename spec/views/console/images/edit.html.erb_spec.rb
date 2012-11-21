require 'spec_helper'

describe "console_images/edit.html.erb" do
  before(:each) do
    @image = assign(:image, stub_model(Console::Image))
  end

  it "renders the edit image form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => console_images_path(@image), :method => "post" do
    end
  end
end
