require "spec_helper"

describe NewspapersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/newspapers" }.should route_to(:controller => "newspapers", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/newspapers/new" }.should route_to(:controller => "newspapers", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/newspapers/1" }.should route_to(:controller => "newspapers", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/newspapers/1/edit" }.should route_to(:controller => "newspapers", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/newspapers" }.should route_to(:controller => "newspapers", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/newspapers/1" }.should route_to(:controller => "newspapers", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/newspapers/1" }.should route_to(:controller => "newspapers", :action => "destroy", :id => "1")
    end

  end
end
