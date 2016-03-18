# This file concerns notifications about replies, particularly, who should
# be notified about new replies.
#
# In order to determine the users to notify about a reply, there are several
# cases to distinguish.


# ## How is the reply sent?
#
# (1) The user may reply via the web ui of brimir.
# 
#       - The ticket system suggests recipients based on the former
#         conversation.
#       - The user can change the recipients in the web form before
#         sending the reply.
#
# (2) The user may reply via email to support@example.com.
# 
#       - The ticket system has to determine who, at least, needs to
#         be notified, since the user just writes to support@example.com,
#         not to the separate clients or agents.
#       - The user might add additional recipients by including them
#         in the `To`, `CC` or `BCC` fields in the email client.


# ## Who is sending the reply?
#
# (a) The reply author can be an agent.
# 
#       - Agents can reply to agents and clients via email to
#         support@example.com.
#       - This mechanism mainly is a convenience shortcut if there is
#         only one possible recipient, i.e. the client that
#         asked the question.
#       
# (b) The reply author can be a client.
#
#       - Clients can only reply to agents via email to
#         support@example.com.
#       - This is to make sure that it is always transparent
#         who will get the reply.
#       - If they need to add other recipients, they can add them
#         in the `To`, `CC` or `BCC` field.


# ## Who is added to `notified_users`?
#
# The association `Reply#notified_users` saves who has been notified
# about a certain reply.
#
# (i) Users that have received a notification through brimir.
#       These can be agents or clients.
#
# (ii) Users that are listed in `To` or `CC` when the reply created
#       via email. These notifications are not sent by brimir,
#       since these recipients receive emails directly from the
#       sender.


# ## Who will be notified by brimir?
#
# (a) If the reply author is an agent:
#
#      The agent always sends replies through the ticket system, either
#      through the web ui (1) or via email to support@example.com (2).
#      Thus, the ticket system is responsible to deliver the reply to the
#      recipients.
#
#      => Send notifications to agents and clients. (1)(a)(i), (2)(a)(i)
#
# (b) If the reply author is a client:
#
#      (1) Through the web ui, there is no sending email client involved.
#
#          => Send notifications to agents and clients. (1)(b)(i)
#
#      (2) Via email to support@example.com, the clients explicitly sends
#          to other clients using the `To`, `CC`, `BCC` fields of his email
#          client. Thus, the ticket system is only responsible to deliver
#          to the agents.
#
#          => Send notifications only to agents. (2)(b)(i)


# ## Who will be listed in `To`, who in `BCC`?
#
#  - (a) In emails to clients, agents are never listed as `To`
#          in order not to reveal the private email addresses
#          of the agents.
#
#  - (b) In emails to clients, other client-recipients' email addresses
#          are listed in `To`. This way, the clients can include
#          the other recipients in their replies intentionally.
#
# In order to distinguish notifications that are to be delivered through
# brimir and notifications that are already sent, the other recipients
# from the `original_message` are added **after** delivering the
# notifications (`reply.notification_mails.each(&:deliver_now)`) in the 
# `NotificationMailer`.


# ## Why is this important.
#
# For an example test case, see:
#   ReplyTest#test_should_not_notify_other_clients_when_one_of_the_clients_replies
#   test/models/reply_test.rb
#
# The issue is discussed on github:
# https://github.com/ivaldi/brimir/issues/259


concern :ReplyNotifications do
  
  included do
    has_many :notifications, as: :notifiable, dependent: :destroy
    has_many :notified_users, source: :user, through: :notifications
  end
  
  def set_default_notifications!(mail_message = nil)
    unless reply_to_type.nil?
      
      self.notified_users = users_to_notify_based_on_ticket_assignment
      
      if self.notified_users.none?
        if mail_message && user && user.client?
          self.notified_users = users_to_notify_based_on_former_reply.where(agent: true)  # (2)(b)(i)
        else
          self.notified_users = users_to_notify_based_on_former_reply  # (1)(a)(i), (2)(a)(i), (1)(b)(i)
        end
      end
      
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
  
  # This is how to deliver the notification emails:
  #
  #     reply.notification_mails.each { |mail| mail.deliver_now }
  #
  # short:
  #
  #     reply.notification_mails.each(&:deliver_now)
  #
  def notification_mails
    self.message_id = Mail::MessageIdField.new.message_id
    self.save!
    
    notified_users.collect do |user|
      unless user.ticket_system_address?
        mail = NotificationMailer.new_reply(self, user)
        mail.message_id = self.message_id
        mail
      end
    end - [nil]
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