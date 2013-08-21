require 'spec_helper'

describe MnAccount do

  	context "touch_success" do
	  	before(:each) do
	  		@mn_account = FactoryGirl.build(:mn_account_new)
	  	end

		it "with plan_type PLAN_TYPE_MONTH" do
			@mn_account.touch_success(MnAccount::PLAN_TYPE_MONTH, MnAccount::ACTIVE_FROM_ALIPAY)
			(@mn_account.service_end_at - 1.month).future?.should eq(true)
		end

		it "with plan_type PLAN_TYPE_THREE_MONTH" do
			@mn_account.touch_success(MnAccount::PLAN_TYPE_THREE_MONTH, MnAccount::ACTIVE_FROM_ALIPAY)
			(@mn_account.service_end_at - 3.months).future?.should eq(true)
		end		
	end

	context "touch_fail" do
		before(:each) do
			@mn_account = FactoryGirl.build(:mn_account_fail_new)
		end

		it "with plan_type PLAN_TYPE_MONTH" do
			@mn_account.touch_faild(MnAccount::PLAN_TYPE_MONTH)
			@mn_account.service_end_at.future?.should eq(true)
		end

	end

	context "bind to user" do
		it "who have one mn_account" do
			mn_account = FactoryGirl.build(:mn_account_new)
			user = User.find(203811)
			bind_mn_account = mn_account.bind_user(user)
			bind_mn_account.should ==(user.mn_account)
		end
		it "who have no mn_account" do
			mn_account = FactoryGirl.build(:mn_account_new)
			user = User.find(206189)
			bind_mn_account = mn_account.bind_user(user)
			mn_account.should ==(bind_mn_account)
		end
	end
end
