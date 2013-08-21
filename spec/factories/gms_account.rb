FactoryGirl.define do

  factory :gms_account_new, class: GmsAccount do
    plan_type 1
    user_id 209429
    last_active_from GmsAccount::ACTIVE_FROM[0]
  end

  factory :gms_account_fail_new, class: GmsAccount do
  end
end