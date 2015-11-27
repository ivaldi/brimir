concern :TicketMerge do
  class_methods do

    # Merge two tickets like this:
    #
    #     separate_tickets = [first_ticket, second_ticket]
    #     merged_ticket = Ticket.merge separate_tickets
    #
    # Options:
    #
    #     current_user: The agent that is performing the merge.
    #       Use the current_user when merging from a controller.
    #
    def merge(separate_tickets, options = {})
      MergedTicket.from separate_tickets, options
    end
    
  end
  
  # When converting separate tickets to a merged ticket, this
  # method allows to convert the message of a ticket to a reply:
  #
  #     reply = ticket.to_reply
  #
  def to_reply
    Reply.new(
      content: self.content,
      created_at: self.created_at,
      updated_at: self.updated_at,
      user_id: self.user_id,
      message_id: self.message_id,
      content_type: self.content_type,
      raw_message_file_name: self.raw_message_file_name,
      raw_message_content_type: self.raw_message_content_type,
      raw_message_file_size: self.raw_message_file_size,
      raw_message_updated_at: self.raw_message_updated_at
    )
  end
  
  # Create an internal note that describes the ticket merge.
  #
  def create_merge_notice(refer_to_ticket, merging_user)
    message = I18n.with_locale(merging_user.locale) {
      I18n.translate :ticket_has_been_merged_to, ticket_id: refer_to_ticket.id
    }
    
    self.replies.create(
      content: message,
      user_id: merging_user.id,
      internal: true
    )
  end
  
end