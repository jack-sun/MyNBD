require "digest/md5"
require 'cgi'
require 'open-uri'
require "net/http"
require "uri"
require 'base64'
module Premium::PremiumUtils

  def self.included(base)
    base.extend         ClassMethods
    base.class_eval do
      include ActiveMerchant::Billing::Integrations     
    end
    base.send :include, InstanceMethods
  end # self.included

  module ClassMethods
    def verify_apple_puchase(receipt_data)
      json_receipt = Hash.new
      #json_receipt["receipt-data"] = Base64.encode64(receipt_data)
      json_receipt["receipt-data"] = receipt_data
      json_receipt["password"] = Settings.apple_purchase_secret

      uri = URI.parse(Settings.apple_verify_url)
      req = Net::HTTP::Post.new(uri.path)

      req.body = JSON.generate(json_receipt)

      http = Net::HTTP.new(uri.host,uri.port)
      http.use_ssl = true

      response = http.request(req)

      json_response = JSON.parse(response.body)
      result = {}
      puts json_response.inspect
      result["status"] = json_response["status"]
      if result["status"] == 0 and Settings.apple_bid == json_response["receipt"]["bid"]
        Settings.apple_product_ids.each do |type, product_id|
          if product_id == json_response["receipt"]["product_id"]
            result["type"] = type.split("_").last
            break
          end
        end
      end
      result["receipt"] = receipt_data
      return result
    end
  end # ClassMethods

  module InstanceMethods
    include ActiveMerchant::Billing::Integrations     

    def verify_apple_puchase(receipt_data)
      json_receipt = Hash.new
      #json_receipt["receipt-data"] = Base64.encode64(receipt_data)
      json_receipt["receipt-data"] = receipt_data
      json_receipt["password"] = Settings.apple_purchase_secret

      uri = URI.parse(Settings.apple_verify_url)
      req = Net::HTTP::Post.new(uri.path)

      req.body = JSON.generate(json_receipt)

      http = Net::HTTP.new(uri.host,uri.port)
      http.use_ssl = true

      response = http.request(req)

      json_response = JSON.parse(response.body)
      result = {}
      Rails.logger.debug json_response.inspect
      result["status"] = json_response["status"]
      if result["status"] == 0 and Settings.apple_bid == json_response["receipt"]["bid"]
        Settings.apple_product_ids.each do |type, product_id|
          if product_id == json_response["receipt"]["product_id"]
            result["type"] = type.split("_").last.to_i
            break
          end
        end
      end
      result["receipt"] = receipt_data
      return result
    end

    def verify_request(notify_id)
      "true" == open("#{Alipay::VERIFY_GATEWAY}?service=notify_verify&partner=#{Alipay::ACCOUNT}&notify_id=#{notify_id}").read
    rescue Exception => e
      return false
    end

    def verify_sign(query_string)
      verify_params = parse(query_string)
      sign_type = verify_params.delete("sign_type")
      sign = verify_params.delete("sign")

      make_sign(verify_params) == sign.try(:downcase)
    end

    def redirect_to_alipay_gateway(options={})
      redirect_to  make_url_by_query_string(options)
    end

    def make_url_by_query_string(options,return_url="http://www.nbd.cn/premium/alipay/notify_mobile")
      Rails.logger.info("=========options:#{options}")
      query_params = {
        :partner => Alipay::ACCOUNT,
        :out_trade_no => options[:out_trade_no],
        :total_fee => options[:amount],
        :seller_email => Alipay::EMAIL,
        :notify_url => Alipay::NOTIFY_URL,
        :body => options[:body],
        :"_input_charset" => 'utf-8',
        :service => Alipay::Helper::CREATE_DIRECT_PAY_BY_USER,
        :payment_type => "1",
        :subject => options[:subject]
      }
      if Rails.env.development?
        query_params = query_params.merge({:return_url => Alipay::NOTIFY_URL})
      end
      if !options[:from].nil?
        # query_params[:notify_url] = "http://www.nbd.cn/premium/alipay/notify_mobile"
        # query_params[:return_url] = "http://www.nbd.cn/premium/alipay/notify_mobile"
        query_params[:return_url] = return_url
      end
      sign = make_sign(query_params)
      params_url_section = query_params.map do |k, value|
        "#{k}=#{CGI.escape(value)}"
      end.join("&")
      return "#{Alipay::COOPERATE_GATEWAY}?#{params_url_section}&sign=#{sign}&sign_type=MD5"
    end

    def create_json_result(mn_account)
      user = mn_account.user
      user_info = Hash.new("")
      user_info = {:id => user.id, :nickname => user.nickname, :email => user.email} if user
         {
          :access_token => mn_account.valid_access_token,
          :trade_num => mn_account.last_trade_num.nil? ? "" : mn_account.last_trade_num,
          :user_info => {
            :user_id => user_info[:id],
            :nickname => user_info[:nickname],
            :email => user_info[:email],
          },
          :touzibao_account => {
            :expiry_at => mn_account.service_end_at.to_i * 1000,
            :alert => {
            :today => Time.now.to_i * 1000,
            :count_down_days_alert => MnAccount::COUNT_DOWN_DAYS_ALERT
            },
            :is_valid => mn_account.account_valid?,
            :plan_type => mn_account.try(:plan_type),
            :last_activated_from => mn_account.last_activated_device.nil? ? "" : mn_account.last_activated_device,
            :last_payment_at => mn_account.last_payment_at.to_i * 1000
          }
        }
    end
    private

    def parse(post)
      params = {}
      for line in post.split('&')
        key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
        params[key] = value
      end
      return params
    end

    def make_sign(query_params)
      temp = query_params.sort.map do |key, value|
              "#{key}=#{CGI.unescape(value)}"
             end.join("&") + Alipay::KEY
      return Digest::MD5.hexdigest(temp)
    end

    def init_accounts(plan_type, active_from)
      @current_account = @current_user.mn_account
      if @current_account.nil?
        @current_account = MnAccount.create(:phone_no => params[:mobile_no], :user_id => @current_user.id, :plan_type => plan_type, :last_active_from => active_from)
      end
      return false unless @current_account.errors.blank?
    end

    def init_payment_with(account, plan_type)
      last_payment = account.payments.last
      if last_payment.nil? or last_payment.success?
        last_payment = account.payments.create(:payment_total_fee => MnAccount::TOTAL_FEE[plan_type], :user_id => @current_user.id, :plan_type => plan_type)
      elsif !last_payment.success?
        last_payment.update_attributes(:payment_total_fee => MnAccount::TOTAL_FEE[plan_type], :user_id => @current_user.id, :plan_type => plan_type)      
      end
      if last_payment.nil? or !last_payment.success?
      end
      @payment = last_payment
    end

  private

    
  end # InstanceMethods
end
