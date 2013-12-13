class TicketParameters < ActionParameter::Base
  def permit
    params.require(:ticket).permit(:content,:user_id,:subject,:status_id,
                                   :assignee_id,:priority_id,:message_id)
  end
end
