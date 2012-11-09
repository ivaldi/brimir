class TicketsController < ApplicationController
  def show
    @ticket = Ticket.find(params[:id])
  end

  def index
    @tickets = Ticket.all
  end
end
