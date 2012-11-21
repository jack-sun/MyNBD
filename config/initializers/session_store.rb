# Be sure to restart your server when you modify this file.

#Nbd::Application.config.session_store :cookie_store, :key => '_nbd_session', :domain => ".nbd.cn"

Nbd::Application.config.session_store :redis_session_store, :domain => Settings.session_domain, :servers => Settings.redis_session_store, :expire_after => 60*40

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Nbd::Application.config.session_store :active_record_store
