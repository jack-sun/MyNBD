require "digest/md5"
require 'cgi'
class MyVerify
	include Premium::PremiumUtils

query_string="service=alipay.wap.trade.create.direct&sign=c7229edde8190fb5ac78df1d19898be3&sec_id=MD5&v=1.0&notify_data=%3Cnotify%3E%3Cpayment_type%3E1%3C%2Fpayment_type%3E%3Csubject%3E%E8%AE%A2%E9%98%85%E6%AF%8F%E6%97%A5%E7%BB%8F%E6%B5%8E%E6%96%B0%E9%97%BB%E6%89%8B%E6%9C%BA%E6%8A%A5%E6%9C%8D%E5%8A%A1+12%E4%B8%AA%E6%9C%88+%E6%89%8B%E6%9C%BA%E5%8F%B7%EF%BC%9A13408025717%3C%2Fsubject%3E%3Ctrade_no%3E2013051752172053%3C%2Ftrade_no%3E%3Cbuyer_email%3E13980098421%3C%2Fbuyer_email%3E%3Cgmt_create%3E2013-05-17+10%3A08%3A03%3C%2Fgmt_create%3E%3Cnotify_type%3Etrade_status_sync%3C%2Fnotify_type%3E%3Cquantity%3E1%3C%2Fquantity%3E%3Cout_trade_no%3Etzb_live_1368756567_1869%3C%2Fout_trade_no%3E%3Cnotify_time%3E2013-05-17+10%3A09%3A40%3C%2Fnotify_time%3E%3Cseller_id%3E2088601172446160%3C%2Fseller_id%3E%3Ctrade_status%3ETRADE_FINISHED%3C%2Ftrade_status%3E%3Cis_total_fee_adjust%3EN%3C%2Fis_total_fee_adjust%3E%3Ctotal_fee%3E0.03%3C%2Ftotal_fee%3E%3Cgmt_payment%3E2013-05-17+10%3A09%3A40%3C%2Fgmt_payment%3E%3Cseller_email%3Emedia%40nbd.com.cn%3C%2Fseller_email%3E%3Cgmt_close%3E2013-05-17+10%3A09%3A39%3C%2Fgmt_close%3E%3Cprice%3E0.03%3C%2Fprice%3E%3Cbuyer_id%3E2088702154040535%3C%2Fbuyer_id%3E%3Cnotify_id%3Ebbac8a602bd614739028baf5392ca18b4y%3C%2Fnotify_id%3E%3Cuse_coupon%3EN%3C%2Fuse_coupon%3E%3C%2Fnotify%3E"
p verify_sign(query_string)
end
