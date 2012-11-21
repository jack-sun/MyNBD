require "spec_helper"

describe StockLivesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/stock_lives" }.should route_to(:controller => "stock_lives", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/stock_lives/new" }.should route_to(:controller => "stock_lives", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/stock_lives/1" }.should route_to(:controller => "stock_lives", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/stock_lives/1/edit" }.should route_to(:controller => "stock_lives", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/stock_lives" }.should route_to(:controller => "stock_lives", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/stock_lives/1" }.should route_to(:controller => "stock_lives", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/stock_lives/1" }.should route_to(:controller => "stock_lives", :action => "destroy", :id => "1")
    end

  end
end
