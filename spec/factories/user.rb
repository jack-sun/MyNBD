FactoryGirl.define do

  factory :user, class: User do
	  email "taijcjc@gmail.com"
	  nickname "jason"
	  password "woshi1989"
  end

  factory :tzb_user, class: User do
    email "tzb_user_1@nbd.com.cn"
    nickname "tzb_user_1"
    password "tzbuser"
  end


end