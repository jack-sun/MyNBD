require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe NewspapersController do

  def mock_newspaper(stubs={})
    @mock_newspaper ||= mock_model(Newspaper, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all newspapers as @newspapers" do
      Newspaper.stub(:all) { [mock_newspaper] }
      get :index
      assigns(:newspapers).should eq([mock_newspaper])
    end
  end

  describe "GET show" do
    it "assigns the requested newspaper as @newspaper" do
      Newspaper.stub(:find).with("37") { mock_newspaper }
      get :show, :id => "37"
      assigns(:newspaper).should be(mock_newspaper)
    end
  end

  describe "GET new" do
    it "assigns a new newspaper as @newspaper" do
      Newspaper.stub(:new) { mock_newspaper }
      get :new
      assigns(:newspaper).should be(mock_newspaper)
    end
  end

  describe "GET edit" do
    it "assigns the requested newspaper as @newspaper" do
      Newspaper.stub(:find).with("37") { mock_newspaper }
      get :edit, :id => "37"
      assigns(:newspaper).should be(mock_newspaper)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created newspaper as @newspaper" do
        Newspaper.stub(:new).with({'these' => 'params'}) { mock_newspaper(:save => true) }
        post :create, :newspaper => {'these' => 'params'}
        assigns(:newspaper).should be(mock_newspaper)
      end

      it "redirects to the created newspaper" do
        Newspaper.stub(:new) { mock_newspaper(:save => true) }
        post :create, :newspaper => {}
        response.should redirect_to(newspaper_url(mock_newspaper))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved newspaper as @newspaper" do
        Newspaper.stub(:new).with({'these' => 'params'}) { mock_newspaper(:save => false) }
        post :create, :newspaper => {'these' => 'params'}
        assigns(:newspaper).should be(mock_newspaper)
      end

      it "re-renders the 'new' template" do
        Newspaper.stub(:new) { mock_newspaper(:save => false) }
        post :create, :newspaper => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested newspaper" do
        Newspaper.stub(:find).with("37") { mock_newspaper }
        mock_newspaper.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :newspaper => {'these' => 'params'}
      end

      it "assigns the requested newspaper as @newspaper" do
        Newspaper.stub(:find) { mock_newspaper(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:newspaper).should be(mock_newspaper)
      end

      it "redirects to the newspaper" do
        Newspaper.stub(:find) { mock_newspaper(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(newspaper_url(mock_newspaper))
      end
    end

    describe "with invalid params" do
      it "assigns the newspaper as @newspaper" do
        Newspaper.stub(:find) { mock_newspaper(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:newspaper).should be(mock_newspaper)
      end

      it "re-renders the 'edit' template" do
        Newspaper.stub(:find) { mock_newspaper(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested newspaper" do
      Newspaper.stub(:find).with("37") { mock_newspaper }
      mock_newspaper.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the newspapers list" do
      Newspaper.stub(:find) { mock_newspaper }
      delete :destroy, :id => "1"
      response.should redirect_to(newspapers_url)
    end
  end

end
