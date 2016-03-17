concern :ReplyNotifications do
  
  included do
    has_many :notifications, as: :notifiable, dependent: :destroy
    has_many :notified_users, source: :user, through: :notifications
  end
  
  def set_default_notifications!
    unless reply_to_type.nil?

      notified_users = reply_to.notified_users
      if Tenant.current_tenant.first_reply_ignores_notified_agents? &&
            reply_to.is_a?(Ticket) &&
            reply_to.assignee.present?
        notified_users = [reply_to.assignee]
      end
    
      self.notified_users =
          ([reply_to.user] + notified_users - [user]).uniq
    else
      result = []
      if ticket.assignee.present?
        result << ticket.assignee
      else
        result = User.agents_to_notify
      end

      ticket.labels.each do |label|
        result += label.users
      end

      self.notified_users = result.uniq
    end
  end
  
  # # This is called from `NotificationMailer#incoming_message` after delivering
  # # the notifications (i).
  # #
  # def add_notifications_based_on_mail_message(mail_message)
  #   self.notified_users << notified_users_based_on_mail_message(mail_message)  # (ii)
  # end
  
  def notify_users
    self.message_id = nil
    notified_users.each do |user|
      mail = NotificationMailer.new_reply(self, user)
      mail.message_id = self.message_id
      mail.deliver_now unless user.ticket_system_address?
      self.message_id = mail.message_id
    end
    self.save!
  end
  
  private
  
  # def notified_users_based_on_mail_message(message)
  #   recipient_emails = message.to.to_a + message.cc.to_a - notified_users.pluck(:email)
  #   recipient_emails.collect { |email| User.where(email: email).first_or_create }
  # end
  
end