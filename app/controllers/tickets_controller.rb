class TicketsController < ApplicationController
  def show
  end

  def index
    @tickets = Ticket.all
  end
end
