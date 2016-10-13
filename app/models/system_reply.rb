class SystemReply < Reply

  def self.create_from_assignment(ticket, template)
    reply = self.create content: template.message, ticket_id: ticket.id
    reply.reply_to = ticket
    reply.set_default_notifications!
    reply.notified_users = (reply.notified_users + [ticket.user] - [ticket.assignee] - [nil]).uniq
    return reply
  end

  def to_partial_path
    'replies/reply'
  end

end
