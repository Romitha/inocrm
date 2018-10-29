source 'https://rubygems.org'

# ruby "2.1.2"
ruby "2.3.8"
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem 'rails', '4.1.2'
gem 'rails', '4.2.1'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
# use postgresql for database active records
gem 'mysql2', '0.3.20' # sudo apt-get install libmysqlclient-dev mysql-client Failed to build gem native extension
# gem 'pg' # sudo apt-get install postgresql postgresql-contrib postgresql-server-dev-all if it failed to build gem native extension.
# Use SCSS for stylesheets
gem "migration_comments"
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development
gem "rack-mini-profiler", group: :development

gem 'devise'

gem "cancan"

gem "rolify"

gem "haml-rails"

gem "carrierwave"
gem "carrierwave-ftp", :require => 'carrierwave/storage/sftp' # SFTP only
gem "mini_magick"
gem 'rmagick' # sudo apt-get install imagemagick libmagickcore-dev libmagickwand-dev if ubuntu shows native library error
# For centos, install like yum install ImageMagick-devel ImageMagick-c++-devel

gem "therubyracer"
gem "less-rails", '~> 2.8.0' #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem 'twitter-bootstrap-rails', "3.2.2"#, :git => 'https://github.com/seyhunak/twitter-bootstrap-rails.git'#, branch: "bootstrap3"

gem "rails-erd"

gem 'simple_form'

gem "nested_form"

gem "mustache"

gem 'kaminari'

# gem 'chosen-sass-bootstrap-rails'
gem "chosen-rails", "1.4.1"

gem 'bootstrap-editable-rails'

gem 'bootstrap-datepicker-rails'

#gem 'remotipart'
gem "jquery-fileupload-rails"
gem 'jcrop-rails-v2'

gem 'momentjs-rails', '>= 2.8.1'
gem 'bootstrap3-datetimepicker-rails', '>= 3.1.3'
gem 'bootstrap-wysihtml5-rails'

gem 'dalli' # sudo apt-get install memcached, yum install memcached

# upgraded version
gem 'web-console', group: :development
gem 'responders'

# gem "handlebars_assets"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
group :development do
  gem 'capistrano', '3.5.0'#, git: "https://github.com/capistrano/capistrano.git"
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-rails-console'
end

group :test do
  gem 'cucumber-rails', :require => false
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
  # gem 'watir'
  #gem 'capybara'
  gem 'selenium-webdriver', '~> 3.0.0.beta3'
  #gem "capybara-webkit" # sudo apt-get install libqt4-dev libqtwebkit-dev
  gem 'rspec-rails'
  gem 'ffaker'
  gem "shoulda-matchers"
end

gem 'httpi'

gem "websocket-rails"
# gem 'redis-rails'
gem 'redcarpet'

gem 'jquery-validation-rails'
gem "roo"
gem "tire", git: "https://github.com/karmi/retire.git"
gem "whenever", :require => false
gem "factory_girl_rails"

# gem "ember-cli-rails"

gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

gem 'backburner'

# gem 'docx', '~> 0.2.07', :require => ["docx"]
gem 'docx_replace'
gem 'rubyzip'
# gem 'htmltoword'
gem 'caracal'
# gem 'omnidocx'

gem 'axlsx', '~> 3.0.0.pre'
gem 'axlsx_rails'

group :production do
  gem 'god' # sudo apt-get install god
  
end


# gem "em-http-request"

# Use debugger
# gem 'debugger', group: [:development, :test]
