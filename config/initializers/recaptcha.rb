# these will only work locally 
# Create your own at https://www.google.com/recaptcha

Recaptcha.configure do |config|
  config.public_key   = Rails.application.secrets[:recaptcha_public_key]
  config.private_key  = Rails.application.secrets[:recaptcha_private_key]
end
