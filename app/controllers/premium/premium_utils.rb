# encoding: utf-8
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
      result["json_response"] = json_response
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
      result["json_response"] = json_response
      return result
    end

    def verify_request(notify_id)
      "true" == open("#{Alipay::VERIFY_GATEWAY}?service=notify_verify&partner=#{Alipay::ACCOUNT}&notify_id=#{notify_id}").read
    rescue Exception => e
      return false
    end

    def verify_sign(query_string, sort_params = true)
      verify_params = parse(query_string)
      sign_type = verify_params.delete("sign_type")
      sign = verify_params.delete("sign")
      Rails.logger.info("===sign:#{sign}")
      Rails.logger.info("===make_sign:#{make_sign(verify_params, sort_params)}")
      make_sign(verify_params, sort_params) == sign.try(:downcase)
    end

    def redirect_to_alipay_gateway(options={})
      redirect_to  make_url_by_query_string(options)
    end


    def make_url_by_query_string(payment)
      alipay_params = payment.generate_alipay_params

      sign = make_sign(alipay_params)
      params_url_section = alipay_params.map do |k, value|
        "#{k}=#{CGI.escape(value)}"
      end.join("&")
      return "#{Alipay::COOPERATE_GATEWAY}?#{params_url_section}&sign=#{sign}&sign_type=MD5"
    end

    def get_wap_alipay_token(payment)
      alipay_params = payment.generate_alipay_params(true)
      sign = make_sign(alipay_params)
      params_url_section = alipay_params.map do |k, value|
        "#{k}=#{CGI.escape(value)}"
      end.join("&")

      uri = URI.parse(Settings.wap_alipay_gateway)
      req = Net::HTTP::Post.new(uri.path)

      req.body = params_url_section+"&sign=#{sign}"

      http = Net::HTTP.new(uri.host,uri.port)
      response = http.request(req)
      body = response.body

      # resonse_body_str = CGI.unescape(body)
      # token_start_index = resonse_body_str.index("<request_token>")
      # tag_length = "<request_token>".length
      # token_end_index = resonse_body_str.index("</request_token>")

      if verify_sign(body)
        token = get_specify_node_data_from_xml(parse(body)["res_data"], "direct_trade_create_res", "request_token")
        # token = resonse_body_str[(token_start_index+tag_length)...token_end_index]
        return token
      else
        return false
      end
    end

    def get_wap_alipay_url(token)
      base_params = "format=xml&partner=#{Alipay::ACCOUNT}&req_data=<auth_and_execute_req><request_token>#{token}</request_token></auth_and_execute_req>&sec_id=MD5&service=#{Settings.wap_alipay_trade_service}&v=2.0"
      sign = Digest::MD5.hexdigest(base_params+Alipay::KEY)
      wap_alipay_url = "#{Settings.wap_alipay_gateway}?#{base_params}&sign=#{sign}"
      return wap_alipay_url
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

    def make_sign(query_params, sort_params = true)
      if sort_params
        temp = query_params.sort
      else
        temp = {:service => query_params["service"], 
                :v => query_params["v"], 
                :sec_id => query_params["sec_id"], 
                :notify_data => query_params["notify_data"]}
      end
      temp = temp.map do |key, value|
              "#{key}=#{CGI.unescape(value)}"
             end.join("&") + Alipay::KEY
      return Digest::MD5.hexdigest(temp)
    end


    def init_accounts(plan_type, active_from, account_type='MnAccount')
      @current_account = @current_user.mn_account
      if @current_account.nil?
        @current_account = MnAccount.create(:phone_no => params[:mobile_no], :user_id => @current_user.id, :plan_type => plan_type, :last_active_from => active_from)
      else
        @current_account.update_attribute(:phone_no, params[:mobile_no]) if params[:mobile_no].present?
      end
      return false unless @current_account.errors.blank?
    end

    def old_init_payment_with(account, plan_type)
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

    def init_payment_with(account, plan_type, payment_device, payment_type)
      total_fee = (account.user && account.user.nickname == "投资宝测试") ? "0.0#{plan_type}".to_f : account.total_fee(plan_type)

      @payment = account.payments.create(:payment_total_fee => total_fee, 
                                         :user_id => account.user_id, 
                                         :plan_type => plan_type, 
                                         :status => Payment::STATUS_WAITE, 
                                         :payment_device => payment_device, 
                                         :payment_type => payment_type)
    end

    def get_specify_node_data_from_xml(xml, root_node, child_node, need_unescape = 'true', return_all = false)
      xml = CGI.unescape(xml) if need_unescape
      xml = REXML::Document.new(xml)
      child_nodes = []
      xml.each_element(root_node) do |element|
        if return_all
          child_nodes << element.elements[child_node].text
        else
          return element.elements[child_node].text
        end
      end
      return child_nodes
    end

  private

    
  end # InstanceMethods
end
