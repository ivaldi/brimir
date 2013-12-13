source 'https://rubygems.org'

gem 'rails', '~> 4.0.0'

gem 'sass-rails', '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'

gem 'uglifier', '>= 1.0.3'

gem 'compass-rails', '~> 1.1.2'
gem 'foundation-rails'

gem 'jquery-rails'

# Zurb form errors
#gem 'foundation_rails_helper', git: 'https://github.com/ivaldi/foundation_rails_helper.git'

group :development do
  # To use debugger
  gem 'debugger'

  gem 'sqlite3'

  # Deploy with Capistrano
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-rvm', '~> 0.1.0'
  gem 'capistrano-rails'
  
  # Debian Wheezy has no nodejs in the repo's :(
  gem 'therubyracer'
end

group :test do
  # for travis-ci
  gem 'rake'

  # for coveralls
  gem 'coveralls', require: false
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

# Markdown
gem 'redcarpet'
