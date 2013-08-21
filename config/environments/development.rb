Nbd::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  
  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false
  
  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true
  
  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = true
  config.cache_store = :redis_store, "redis://cache.nbd.cn:6379/14" # move this configuration to config/initializes/redis.rb
  
  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  #config.action_mailer.default_url_options = { :host => Settings.host } # move this configuration to config/initializes/nbd_common.rb
  
  # config.action_mailer.delivery_method = :sendmail
  # Defaults to:
  # config.action_mailer.sendmail_settings = {
  #   :location => '/usr/sbin/sendmail',
  #   :arguments => '-i -t'
  # }
  
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
  
  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  config.action_controller.asset_host = "http://static.nbd.cn"

  ##### config for bullet
  config.after_initialize do
    Bullet.enable = true # enable Bullet gem, otherwise do nothing
    # Bullet.alert = true # pop up a JavaScript alert in the browser
    Bullet.bullet_logger = true # log to the Bullet log file (Rails.root/log/bullet.log)
    Bullet.console = true # log warnings to your browser's console.log (Safari/Webkit browsers or Firefox w/Firebug installed)
    # Bullet.growl = true # pop up Growl warnings if your system has Growl installed. Requires a little bit of configuration
    # Bullet.xmpp = { :account  => 'bullets_account@jabber.org',
    #                 :password => 'bullets_password_for_jabber',
    #                 :receiver => 'your_account@jabber.org',
    #                 :show_online_status => true } # send XMPP/Jabber notifications to the receiver indicated
    Bullet.rails_logger = true # add warnings directly to the Rails log
    # Bullet.airbrake = true # add notifications to airbrake
  end
  #####
end
