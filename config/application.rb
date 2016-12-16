require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Brimir
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Change this to :ldap_authenticatable to use ldap
    config.devise_authentication_strategy = :database_authenticatable
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [:en]
  end
end
