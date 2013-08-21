require "base64"

module Nbd::KoubeibangUtils
  def encode_thumbed_cookies(cookies)
    Base64.encode64(encode_thumbed_cookies_to_json(cookies))
  end

  def decode_thumbed_cookies(cookies)
    decode_thumbed_cookies_from_json(Base64.decode64(cookies))
  end

  def encode_thumbed_cookies_to_json(cookies)
    ActiveSupport::JSON.encode(cookies)
  end

  def decode_thumbed_cookies_from_json(cookies)
    ActiveSupport::JSON.decode(cookies)
  end
end