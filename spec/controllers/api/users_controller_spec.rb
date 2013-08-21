#encoding: utf-8
require 'spec_helper'

describe Api::UsersController do

	describe "get user info" do
		describe "with right app_key" do
			it "and right access_token" do
				get :account, :app_key => Settings.iphone_app_key, :access_token => '173b98594068fe6747429d01b6f5b5aa'
				response.status.should eq(200)
			end

			# it "and nil access_token" do
			# 	get :account, :app_key => 'aa551d8a948ada5ee2a102fbe93574f0'
			# 	response.status.should eq(401)
			# end

			it "and wrong access_token" do
				get :account, :app_key => Settings.iphone_app_key, :access_token => 'teststaet'
				response.status.should eq(401)
			end		
		end

		it "with wrong access_token" do
			get :account, :app_key => "test_app_key"
			response.status.should eq(401)
		end
	end

	describe "sign up a new user" do
		it "with right params" do
			post :create, :app_key => Settings.iphone_app_key, :nickname => "tzb_user", :email => "tzb_test_1@nbd.com.cn", :password => "tonytone"
			response.status.should eq(200)
			response.body.should include 'expiry_at'
			info = JSON.parse(response.body)
			mn_account = MnAccount.where("access_token = ?", info['access_token']).first
			mn_account.gift_details.should ==("赠送7天")
		end

		it "with right params and phone_no" do
			post :create, :app_key => Settings.iphone_app_key, :nickname => "tzb_user", :email => "tzb_test_1@nbd.com.cn", :password => "tonytone", :phone_no => "13408025717"
			response.status.should eq(200)
			response.body.should include 'expiry_at'
			info = JSON.parse(response.body)
			mn_account = MnAccount.where("access_token = ?", info['access_token']).first
			mn_account.gift_details.should ==("赠送14天")
		end		

		it "with repeat nickname" do
			post :create, :app_key => Settings.iphone_app_key, :nickname => "财经你好", :email => "tzb_test_1@nbd.com.cn", :password => "tonytone"
			response.status.should eq(401)
			response.body.should include 'nickname'
		end

		it "with repeat email" do
			post :create, :app_key => Settings.iphone_app_key, :nickname => "tzb_user", :email => "348281683@qq.com", :password => "tonytone"
			response.status.should eq(401)
			response.body.should include 'email'
		end		

		it "with repeat email and nickname" do
			post :create, :app_key => Settings.iphone_app_key, :nickname => "财经你好", :email => "348281683@qq.com", :password => "tonytone"
			response.status.should eq(401)
			response.body.should include 'nickname'
			response.body.should include'email'
		end
	end

	describe "user sign in" do
		it "with right trade_num" do
			post :sign_in, :trade_num => '086qyu', :app_key => Settings.iphone_app_key
			response.status.should eq(200)
		end

		it "with wrong trade_num" do
			post :sign_in, :trade_num => 'xxx', :app_key => Settings.iphone_app_key
			response.status.should eq(401)
		end

		describe "with right account" do
			it "and no access_token" do
				post :sign_in, :nickname => '348281683@qq.com', :password => 'tonytone', :app_key => Settings.iphone_app_key
				response.status.should eq(200)
			end

			it "and unbind access_token" do
				post :sign_in, :nickname => '348281683@qq.com', :password => 'tonytone', :app_key => Settings.iphone_app_key, :access_token => '3c968bd934a96fac0895e3a6cd481138'
				response.status.should eq(200)
				info = JSON.parse(response.body)
				puts info.inspect
				mn_account = MnAccount.where("access_token = ?", info['access_token']).first
				mn_account.user_id.should eq(info['user_info']['user_id'])
			end

			# it "and bind access_token" do
			# 	post :sign_in, :nickname => '348281683@qq.com', :password => 'tonytone', :app_key => Settings.iphone_app_key, :access_token => '3c968bd934a96fac0895e3a6cd481138'
			# 	response.status.should eq(200)
			# 	info = JSON.parse(response.body)
			# 	puts info.inspect
			# 	mn_account = MnAccount.where("access_token = ?", info['access_token']).first
			# 	mn_account.user_id.should eq(info['user_info']['user_id'])
			# end
		end
	end
end
