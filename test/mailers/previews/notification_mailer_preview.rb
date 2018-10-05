ActiveRecord::Base.establish_connection(:test)
puts Rails.env

class NotificationMailerPreview < ActionMailer::Preview

  def new_account
    NotificationMailer.new_account(
      User.find_by(email: 'alice@xxxx.com'),
      EmailTemplate.find_by(kind: 'user_welcome'),
      Tenant.find_by(domain: 'test.host').tap { |t| t.notify_user_when_account_is_created = true }
    )
  end

  I18n.available_locales.each do |locale|

    # TODO: With Rails 5 and above, the +params+ has is available in mailer
    #       previews and therefore can be used to set the locale.
    next if ENV['MAILER_PREVIEW_LOCALE'] && locale.to_s != ENV['MAILER_PREVIEW_LOCALE']

    define_method("new_ticket__#{locale}") do
      NotificationMailer.new_ticket(
        Ticket.find_by(message_id: 'test123@test123'),
        User.find_by(email: 'alice@xxxx.com').tap { |u| u.locale = locale }
      )
    end

    define_method("new_reply__#{locale}") do
      NotificationMailer.new_reply(
        Reply.find_by(message_id: 'reply123@reply123'),
        User.find_by(email: 'alice@xxxx.com').tap { |u| u.locale = locale }
      )
    end

    define_method("assigned__#{locale}") do
      NotificationMailer.assigned(
        Ticket.find_by(message_id: 'test123@test123').tap { |t| t.assignee.locale = locale }
      )
    end

    define_method("status_changed__#{locale}") do
      NotificationMailer.status_changed(
        Ticket.find_by(message_id: 'test123@test123').tap { |t| t.assignee.locale = locale }
      )
    end

    define_method("priority_changed__#{locale}") do
      NotificationMailer.priority_changed(
        Ticket.find_by(message_id: 'test123@test123').tap { |t| t.assignee.locale = locale }
      )
    end

  end
end
