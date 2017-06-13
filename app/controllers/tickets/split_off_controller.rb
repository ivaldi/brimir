class Tickets::SplitOffController < ApplicationController

  def create
    reply = Reply.find(params[:reply_id])
    authorize! :split_off, reply

    ticket = reply.to_ticket

    if params[:selected_text]
      # If the agent has selected text when splitting off the ticket
      # then a new ticket is created with just that text.
      # This is useful if the client has presented several issues
      # in one ticket.
      ticket.content = params[:selected_text]
      ticket.subject = ticket.content.first(100)
    else
      # If the agent has not selected text, the reply is just converted
      # into a ticket. The reply can be destroyed as the complete reply
      # has been extracted into a ticket.
      reply.destroy
    end

    ticket.save

    respond_to do |format|
      format.html { redirect_to ticket }
      format.json { render json: { ticket_path: ticket_path(ticket) } }
    end
  end

end