class EmailImportsController < ApplicationController

  def new
    authorize! :create, :email_imports
  end

  def create
    authorize! :create, :email_imports

    params[:files].each do |uploaded_file|
      message = uploaded_file.tempfile.read
      ticket = TicketMailer.receive(message)
      NotificationMailer.incoming_message(ticket, message)
    end

    if params[:files].count == 1
      redirect_to ticket_path(Ticket.last)
    else
      redirect_to tickets_path
    end
  end

end