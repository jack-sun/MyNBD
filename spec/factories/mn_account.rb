FactoryGirl.define do

  factory :mn_account_new, class: MnAccount do
    service_end_at nil
    created_at Time.now
    plan_type 1
    last_active_from MnAccount::ACTIVE_FROM_ALIPAY
    user_id 203811
  end

  factory :mn_account_fail_new, class: MnAccount do
    service_end_at Time.now
    created_at Time.now
    plan_type 1
    last_active_from MnAccount::ACTIVE_FROM_ALIPAY
  end
end