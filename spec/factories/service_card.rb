FactoryGirl.define do

  factory :common_card, class: ServiceCard do
  	card_no 'test_service_card_no'
  	password 'test_service_card_password'
  end

  factory :used_card, class: ServiceCard, parent: :common_card do
  	status ServiceCard::STATUS_ACTIVATED
  end

  factory :unused_card, class: ServiceCard, parent: :common_card do
  	status ServiceCard::STATUS_UNACTIVATED
  end    

end