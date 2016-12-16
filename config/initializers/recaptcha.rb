# these will only work locally 
# Create your own at https://www.google.com/recaptcha

Recaptcha.configure do |config|
  config.site_key   = Rails.application.secrets[:recaptcha_site_key]
  config.secret_key  = Rails.application.secrets[:recaptcha_secret_key]
end
