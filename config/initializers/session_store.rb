# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_inova_crm_session'
Rails.application.config.session_store ActionDispatch::Session::CacheStore, :expire_after => 120.minutes, key: '_inova_crm_session'