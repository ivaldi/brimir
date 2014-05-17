source 'https://rubygems.org'

gem 'rails', '~> 4.1.0'

gem 'sass-rails', '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'

gem 'uglifier', '>= 1.0.3'

gem 'compass-rails', '~> 1.1.2'
gem 'foundation-rails', '~> 5.2.2'

gem 'jquery-rails'

# Zurb form errors
gem 'foundation_rails_helper'

group :development do
  # To use debugger
  gem 'byebug'

  gem 'sqlite3'

  # Deploy with Capistrano
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-rvm', '~> 0.1.0'
  gem 'capistrano-rails'

  # Debian Wheezy has no nodejs in the repo's :(
  gem 'therubyracer'

  # Spring application pre-loader
  gem 'spring'
end

group :test do
  # for travis-ci
  gem 'rake'

  # for coveralls
  gem 'coveralls', require: false
end

group :production do
  # if either of these please you ...
  # gem 'pg'
  # gem 'mysql2'
end

# Authentication
gem 'devise'

# Authorization
gem 'cancan'

# Pagination
gem 'will_paginate'

# Attachments, thumbnails etc
gem 'paperclip'

# Markdown
gem 'redcarpet'

#select2 replacement for selectboxes
gem 'select2-rails'
