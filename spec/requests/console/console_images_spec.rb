require 'spec_helper'

describe "Console::Images" do
  describe "GET /console_images" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get console_images_path
      response.status.should be(200)
    end
  end
end
