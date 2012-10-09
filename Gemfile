source 'https://rubygems.org'

gem 'rails', '3.2.8'
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
gem "twitter-bootstrap-rails"
gem 'jquery-rails'
gem "haml"
gem "devise"
gem "simple_form"
gem 'paperclip'
gem 'rmagick'
gem 'faker'
gem 'bootstrap-will_paginate'
gem "cancan"
gem 'json'

group :development do 
  gem "haml-rails"
  gem 'heroku_san'
  gem 'rails-erd'

  # For HAML
  gem 'ruby_parser', '>= 2.3.1'
  gem "hpricot", ">= 0.8.5"
end

group :development, :test do
  gem "rspec-rails", ">= 2.11.0"
  gem "capybara"
  gem "database_cleaner", '>= 0.8.0'
  gem "faker"
end
