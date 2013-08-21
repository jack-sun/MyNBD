FactoryGirl.define do

  factory :common_payment, class: Payment do
  	status Payment::STATUS_WAITE
  	plan_type 0
  end

  factory :mn_account_payment, class: Payment, parent: :common_payment do
  	association :service, factory: :mn_account_new
  end  

end