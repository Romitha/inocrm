Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true
  config.cache_store = :dalli_store, nil, { :namespace => "inovcrm", :expires_in => 1.day, :compress => true }

  dir = File.dirname("log/inocrm/#{Date.today.strftime('%m')}/#{Date.today.strftime('%d')}/#{Date.today.strftime('%m-%d')}-#{Rails.env}.log")

  FileUtils.mkdir_p(dir) unless File.directory?(dir)
  # File.chmod 0777, Rails.root.join('log', 'inocrm', '08', '03', '08-03-development.log')

  config.logger = Logger.new("#{dir}/#{Date.today.strftime('%m-%d')}-#{Rails.env}.log")

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = false

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  config.assets.initialize_on_precompile = false

  # config.action_mailer.smtp_settings = {
  #   # address: "tipsanit.railsplayground.net",
  #   # port: 25,
  #   # domain: "tipsanity.com",
  #   # user_name: "no_reply@tipsanity.com",
  #   # password: "FHnhaM!q@lrc",
  #   # authentication: :login,
  #   # enable_starttls_auto: false
  # }

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    # address: 'smtp.gmail.com',
    # authentication: :login,
    # enable_starttls_auto: true,
    # port: 587,
    :address              => "inovaitsys.com",
    :authentication       => :plain,
    :enable_starttls_auto => false,
    :port                 => 25,
    :domain               => "mail.inovaitsys.com",
    :user_name            => "inocrmtest@inovaitsys.com",
    :password             => "INOVA951",
  }

  config.middleware.delete Rack::Lock

  config.web_console.whiny_requests = false

  # # config/application.rb

  # config.web_console.whitelisted_ips = '192.168.1.5'
  # # or a whole network
  # config.web_console.whitelisted_ips = '192.168.0.0/16'

end
