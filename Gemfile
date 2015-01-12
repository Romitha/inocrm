source 'https://rubygems.org'

ruby "2.1.2"
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.2'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3'
# use postgresql for database active records
gem 'mysql2' # sudo apt-get install libmysqlclient-dev Failed to build gem native extension
gem 'pg' # sudo apt-get install postgresql postgresql-contrib postgresql-server-dev-all if it failed to build gem native extension.
# Use SCSS for stylesheets
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
gem 'rmagick' # sudo apt-get install libmagickwand-dev and imagemagick if ubuntu shows native library error

gem "therubyracer"
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem 'twitter-bootstrap-rails', :git => 'https://github.com/seyhunak/twitter-bootstrap-rails.git', branch: "bootstrap3"

gem "rails-erd"

gem 'simple_form'

gem "nested_form"

gem "mustache"

# gem 'chosen-sass-bootstrap-rails'
gem "chosen-rails"

gem 'bootstrap-editable-rails'

gem 'bootstrap-datepicker-rails'

#gem 'remotipart'
gem "jquery-fileupload-rails"
gem 'jcrop-rails-v2'

# gem "handlebars_assets"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
group :development do
  gem 'capistrano'#, git: "https://github.com/capistrano/capistrano.git"
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
end

# Use debugger
# gem 'debugger', group: [:development, :test]
