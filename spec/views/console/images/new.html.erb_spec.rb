require 'spec_helper'

describe "console_images/new.html.erb" do
  before(:each) do
    assign(:image, stub_model(Console::Image).as_new_record)
  end

  it "renders new image form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => console_images_path, :method => "post" do
    end
  end
end
