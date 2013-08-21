#encoding: utf-8
require 'spec_helper'

describe Premium::MobileNewspaperAccountsController do
	describe "activate MnAccount" do
		it "with wrong mobile_no" do
			request.session['user_id'] = '203811'
			post :activate, :password => 'nbd3690949250959', :mobile_no => '138025717'
			response.should render_template("new")
		end

		it "with unused serviceCard" do
			request.session['user_id'] = '203811'
			post :activate, :password => 'nbd3690949250959', :mobile_no => '13408025717'
			assigns(:service_card).status_valid?.should eq(false)
			response.should redirect_to(success_premium_mobile_newspaper_account_url)
		end

		it "with used serviceCard" do
			request.session['user_id'] = '203811'
			post :activate, :password => 'nbd8720259812397', :mobile_no => '13408025717'
			assigns(:service_card).status_valid?.should eq(false)
			response.should render_template("new")
		end		
	end
end
