class TicketsController < ApplicationController
  def show
    @ticket = Ticket.find(params[:id])
  end

  def index
    @tickets = Ticket.all
    @users = User.all
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
