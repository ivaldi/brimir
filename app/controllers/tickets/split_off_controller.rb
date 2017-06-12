class Tickets::SplitOffController < ApplicationController

  def create
    reply = Reply.find(params[:reply_id])
    authorize! :split_off, reply

    ticket = reply.to_ticket
    ticket.save
    reply.destroy

    redirect_to ticket
  end

end