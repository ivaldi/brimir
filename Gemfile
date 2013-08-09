source 'https://rubygems.org'

gem 'rails', '~> 4.0.0'

gem 'sass-rails', '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'

gem 'uglifier', '>= 1.0.3'

gem 'compass-rails', github: 'milgner/compass-rails', branch: 'rails4'
gem 'zurb-foundation', '~> 3.2.0'

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
