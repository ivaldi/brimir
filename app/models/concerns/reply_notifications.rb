concern :ReplyNotifications do
  
  included do
    has_many :notifications, as: :notifiable, dependent: :destroy
    has_many :notified_users, source: :user, through: :notifications
  end
  
  def set_default_notifications!
    unless reply_to_type.nil?
      
      self.notified_users = users_to_notify_based_on_ticket_assignment
      self.notified_users = users_to_notify_based_on_former_reply if self.notified_users.none?
      
      self.notified_users.uniq!

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
  
  def users_not_to_notify
    # Do not notify the user that is sending the reply.
    # Also, do not notify the ticket system email addresses to prevent
    # email loops.
    [user] + User.ticket_system_addresses
  end
  
  def users_to_notify_based_on_former_reply
    if reply_to
      User.where(id: ([reply_to.user] + reply_to.notified_users - users_not_to_notify).map(&:id)) 
    else
      User.none
    end
  end
  
  def users_to_notify_based_on_ticket_assignment
    if Tenant.current_tenant.first_reply_ignores_notified_agents? &&
         reply_to.is_a?(Ticket) &&
         reply_to.assignee.present?
      return [reply_to.user, reply_to.assignee] - users_not_to_notify
    else
      return []
    end
  end
  
  # def notified_users_based_on_mail_message(message)
  #   recipient_emails = message.to.to_a + message.cc.to_a - notified_users.pluck(:email)
  #   recipient_emails.collect { |email| User.where(email: email).first_or_create }
  # end
  
end