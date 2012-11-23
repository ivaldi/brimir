class TicketsController < ApplicationController
  def show
    @ticket = Ticket.find(params[:id])
    @users = User.all
    @statuses = Status.all
    @reply = Reply.new
  end

  def index
    @users = User.all
    @statuses = Status.all

    @tickets = Ticket.order(:created_at)

    if !params[:status_id].nil?
      @tickets = @tickets.where(status_id: params[:status_id])
    end

    if !params[:assignee_id].nil?
      @tickets = @tickets.where(assignee_id: params[:assignee_id])
    end

    @tickets = @tickets.page(params[:page])
  end

  def update
    @ticket = Ticket.find(params[:id])

    respond_to do |format|
      if @ticket.update_attributes(params[:ticket])
        format.html { redirect_to @ticket, notice: 'Ticket was successfully updated.' }
        format.js { render notice: 'Ticket was succesfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end
end
