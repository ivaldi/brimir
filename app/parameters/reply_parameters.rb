class ReplyParameters < ActionParameter::Base
  def permit
    params.require(:reply).permit(:content, :ticket_id, :message_id, :user_id,
                                  :attachments_attributes, :to, :cc, :bcc)
  end
end
