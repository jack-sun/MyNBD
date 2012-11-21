Nbd::Application.configure do

  # action mailer
  config.action_mailer.default_url_options = { :host => Settings.host }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
  :address              => "smtp.qiye.163.com",
  :port                 => 25,
  :domain               => 'www.nbd.com.cn',
  :user_name            => 'info@nbd.com.cn',
  :password             => 'nbd9780xs',
  :authentication       => 'plain',
  :enable_starttls_auto => true  }
  
end
