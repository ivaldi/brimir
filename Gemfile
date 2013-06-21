source 'https://rubygems.org'

gem 'rails', '~> 3.2.8'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  gem 'uglifier', '>= 1.0.3'

  gem 'compass-rails'
  gem 'zurb-foundation', '~> 3.2.0'
end

gem 'jquery-rails'

group :development do
  # To use debugger
  gem 'debugger'

  gem 'sqlite3'

  # Deploy with Capistrano
  gem 'capistrano'
  gem 'rvm-capistrano'
  
  # Debian Wheezy has no nodejs in the repo's :(
  gem 'therubyracer'
end

group :test do
  # for travis-ci
  gem 'rake'
end

group :production do
  # PostgreSQL for production
  gem 'pg'
end

# Authentication
gem 'devise'

# Pagination
gem 'will_paginate'

# Attachments, thumbnails etc
gem 'paperclip'
