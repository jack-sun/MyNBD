Rails.application.config.middleware.use OmniAuth::Builder do
  #  configure do |config|
  #    config.path_prefix = '/myapp/auth' if RAILS_ENV == 'production'
  #  end
  
  #provider :facebook, 'APP_ID', 'APP_SECRET'
  
  #provider :tsina, '562534416', '41488f4783127286cb1c17f364a73c3f'
  #provider :tsina, '1206779547', 'a5a7404ca6a4e20d1a9574c47b8fd68a'
  
  provider :weibo, '2934169357', 'f4af4864997a00ddff7e1765e643f9ec'
  #provider :weibo, "2192683619", "46100675d2d19aba5a214a674888c908"
  #provider :taobao, '21177876', '8e4ae23086c3c1c5b63a37b7675bbd84'
  provider :qq_connect, '100305882', 'efb48357f8de52fbfd86e650167684c5'
end
