require 'active_merchant'
require 'activemerchant_patch_for_china'

ActiveMerchant::Billing::Integrations::Alipay::KEY = "zfs6otwxikylbynkujdiw7eyrzskrnuh"
ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT = "2088601172446160"
ActiveMerchant::Billing::Integrations::Alipay::EMAIL = "media@nbd.com.cn"
ActiveMerchant::Billing::Integrations::Alipay::COOPERATE_GATEWAY = "https://mapi.alipay.com/gateway.do"
ActiveMerchant::Billing::Integrations::Alipay::VERIFY_GATEWAY = "https://mapi.alipay.com/gateway.do?service=notify_verify"
ActiveMerchant::Billing::Integrations::Alipay::NOTIFY_URL = if Rails.env.production?
  "http://www.nbd.com.cn/premium/alipay/notify"
else
  "http://www.nbd.cn/premium/alipay/notify"
end
ActiveMerchant::Billing::Integrations::Alipay::WAP_NOTIFY_URL = if Rails.env.production?
	"http://www.nbd.com.cn/premium/alipay/wap_notify"
else
	"http://www.nbd.cn/premium/alipay/wap_notify"
end
