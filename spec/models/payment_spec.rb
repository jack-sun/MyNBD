require 'spec_helper'

describe Payment do

	context "set_success_from_card" do
		before(:each) do
			@payment = FactoryGirl.build(:mn_account_payment)
			puts @payment.inspect
		end
		it "with used card" do
			card = FactoryGirl.build(:used_card)
			@payment.set_success_from_card(card)
			@payment.status.should eq(0)
			card.status.should eq(1)
		end
		it "with unused card" do
			card = FactoryGirl.build(:unused_card)
			@payment.set_success_from_card(card)
			@payment.status.should eq(1)
			card.status.should eq(1)
		end		
	end

	context "init payment" do
		context "with mn_account" do
			before(:each) do
				@mn_account = FactoryGirl.create(:mn_account_new)
			end
			it "and one month plan_type" do
				payment = Payment.init_payment_with(@mn_account, MnAccount::PLAN_TYPE_MONTH)
				payment.service.should eq(@mn_account)
				payment.plan_type.should eq(MnAccount::PLAN_TYPE_MONTH)
			end
			it "and three month plan_type" do
				payment = Payment.init_payment_with(@mn_account, MnAccount::PLAN_TYPE_THREE_MONTH)
				payment.service.should eq(@mn_account)
				payment.plan_type.should eq(MnAccount::PLAN_TYPE_THREE_MONTH)
			end			
		end
		context "with gms_account" do
			before(:each) do
				@gms_account = FactoryGirl.create(:gms_account_new)
				puts @gms_account.inspect
			end
			it "and basic plan_type" do
				payment = Payment.init_payment_with(@gms_account, 0)
				payment.service.should eq(@gms_account)
				payment.plan_type.should eq(0)
			end
			it "and vip plan_type" do
				payment = Payment.init_payment_with(@gms_account, 1)
				payment.service.should eq(@gms_account)
				payment.plan_type.should eq(1)
			end			
		end		
	end	

end
