namespace :secret do

  desc "Display the key to use in incoming mail hook URLs"
  task mail_key: :environment do
    puts TicketsController::MAIL_KEY
  end

end
