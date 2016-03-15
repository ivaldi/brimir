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
  
end