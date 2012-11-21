require "spec_helper"

describe Console::ImagesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/console_images" }.should route_to(:controller => "console_images", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/console_images/new" }.should route_to(:controller => "console_images", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/console_images/1" }.should route_to(:controller => "console_images", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/console_images/1/edit" }.should route_to(:controller => "console_images", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/console_images" }.should route_to(:controller => "console_images", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/console_images/1" }.should route_to(:controller => "console_images", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/console_images/1" }.should route_to(:controller => "console_images", :action => "destroy", :id => "1")
    end

  end
end
