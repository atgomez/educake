source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'thin'

# Remember to update bundler to pre by $gem install bundler --pre
ruby '1.9.3'
gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :development do 
  gem "haml-rails"
  gem 'rails-erd'

  # For HAML
  gem 'ruby_parser', '>= 2.3.1'
  gem "hpricot", ">= 0.8.5"
  gem 'therubyracer', :platforms => :ruby

  # For models annotation
  gem 'annotate', ">=2.5.0"

  # For API doc
  gem 'coderay'
  gem 'kramdown', '~> 0.13.2'
  gem 'mime-types', '~> 1.16'
  gem 'nanoc', '~> 3.4.3'
  gem 'nokogiri'
  gem 'pygments.rb'
  gem 'yajl-ruby', '~> 0.8.2'
end

group :development, :test do
  gem "rspec-rails", ">= 2.11.0"
  gem "capybara"
  gem "database_cleaner", '>= 0.8.0'
  gem "faker"
  gem "factory_girl_rails", '>= 4.1.0'
  # For code coverage
  gem "simplecov", :require => false
  gem "simplecov-rcov", :require => false
  gem "shoulda-matchers"
  gem "spork-rails", "~> 3.2.1"
end

gem "twitter-bootstrap-rails"
gem "less-rails"
gem 'jquery-rails'
gem "haml"
gem "devise", ">= 2.0.0"
gem "simple_form"
gem 'paperclip'
gem "aws-sdk" 
gem 'rmagick'
gem 'faker'
gem 'bootstrap-will_paginate'
gem "better_states_select"
#gem 'event-calendar', :require => 'event_calendar'
gem "cancan"
gem 'json'
gem 'meta_search'
gem 'newrelic_rpm'
gem 'fastercsv'
gem "remotipart", "~> 1.0"
gem "oauth-plugin", ">= 0.4.0.rc2"

#Excel Parser
gem "axlsx"

# Client Validation
gem 'client_side_validations'
gem 'client_side_validations-simple_form'

# Logging
gem "mongodb_logger", :git => 'git://github.com/le0pard/mongodb_logger.git', :branch => 'master'
gem "moped"

# Database Site
gem 'rails_admin'

# API
gem 'grape'
gem 'grape-rabl'
gem 'grape_doc'
