require 'active_merchant'
require 'activemerchant_patch_for_china'

ActiveMerchant::Billing::Integrations::Alipay::KEY = "zfs6otwxikylbynkujdiw7eyrzskrnuh"
ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT = "2088601172446160"
ActiveMerchant::Billing::Integrations::Alipay::EMAIL = "media@nbd.com.cn"
ActiveMerchant::Billing::Integrations::Alipay::COOPERATE_GATEWAY = "https://www.alipay.com/cooperate/gateway.do"
ActiveMerchant::Billing::Integrations::Alipay::VERIFY_GATEWAY = "https://mapi.alipay.com/gateway.do"
ActiveMerchant::Billing::Integrations::Alipay::NOTIFY_URL = nil
if Rails.env.development?
  ActiveMerchant::Billing::Integrations::Alipay::NOTIFY_URL = "http://www.nbd.cn/premium/alipay/notify"
else
  ActiveMerchant::Billing::Integrations::Alipay::NOTIFY_URL = "http://www.nbd.com.cn/premium/alipay/notify"
end
