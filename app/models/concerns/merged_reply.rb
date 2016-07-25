# This module concerns Replies.
# Replies can be `merged?`, i.e. be copies of Tickets or other Replies
# after merging tickets.
#
# Raw messages and attachments are not copied when merigng. Thus, we
# need to redirect calls to `raw_message` and `attachments` to the
# original object.
#
# Attention! This module needs to be prepended, not included. This is
# because carrierwave defines the `raw_message` method using `define_method`.
# The method override in this module is just ignored if the module is
# included due to the lookup order for methods.
# See also: https://www.ruby-forum.com/topic/195231
#
concern :MergedReply do

  def result_of_merge?
    true if original_ticket_or_reply_before_merge
  end

  def original_ticket_or_reply_before_merge
    if message_id
      @original_ticket_or_reply_before_merge ||= Ticket.merged.where(message_id: message_id).first || Reply.where(message_id: message_id).where('id < ?', id).first
    end
  end

  def attachments
    original_ticket_or_reply_before_merge.try(:attachments) || super
  end

  def raw_message
    if super.try(:path, :original) && File.file?(super.path(:original))
      super
    elsif original_ticket_or_reply_before_merge.try(:raw_message?)
      original_ticket_or_reply_before_merge.raw_message
    else
      super
    end
  end

  def raw_message?
    raw_message.try(:path, :original) && File.file?(raw_message.path(:original))
  end
end