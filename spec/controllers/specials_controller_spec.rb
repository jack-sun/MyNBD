require 'spec_helper'

describe SpecialsController do

  describe "GET 'wishwall'" do
    it "should be successful" do
      get 'wishwall'
      response.should be_success
    end
  end

end
