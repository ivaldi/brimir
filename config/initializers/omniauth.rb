Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :google_oauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET']
  # handle errors during 3rd party login
  on_failure { |env| AuthenticationsController.action(:failure).call(env) }
end
