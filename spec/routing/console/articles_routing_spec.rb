require "spec_helper"

describe Console::ArticlesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/console/articles" }.should route_to(:controller => "console/articles", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/console/articles/new" }.should route_to(:controller => "console/articles", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/console/articles/1" }.should route_to(:controller => "console/articles", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/console/articles/1/edit" }.should route_to(:controller => "console/articles", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/console/articles" }.should route_to(:controller => "console/articles", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/console/articles/1" }.should route_to(:controller => "console/articles", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/console/articles/1" }.should route_to(:controller => "console/articles", :action => "destroy", :id => "1")
    end

  end
end
