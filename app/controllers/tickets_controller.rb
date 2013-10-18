# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012 Ivaldi http://ivaldi.nl
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class TicketsController < ApplicationController
  before_filter :authenticate_user!, except: [ :create ] 

  def show
    @ticket = Ticket.find(params[:id])
    @agents = User.agents
    @statuses = Status.all
    @priorities = Priority.all    

    @reply = @ticket.replies.new
    @reply.to = @ticket.user.email
  end

  def index
    @agents = User.agents
    @statuses = Status.all
    @priorities = Priority.all

    @status_filter = params[:status_id]
    @tickets = Ticket.order(:created_at).by_status(@status_filter)

    if !params[:assignee_id].nil?
      
      # unassigned
      if params[:assignee_id].to_i == 0
        @tickets = @tickets.where(assignee_id: nil)
      else
        @tickets = @tickets.where(assignee_id: params[:assignee_id])
      end

    end

    @tickets = @tickets.page(params[:page])
  end

  def update
    @ticket = Ticket.find(params[:id])

    if !params[:ticket][:assignee_id].nil? \
        && @ticket.assignee_id != params[:ticket][:assignee_id]
      assignee_changed = true
    else
      assignee_changed = false
    end

    if !params[:ticket][:status_id].nil? \
        && @ticket.status_id != params[:ticket][:status_id]
      status_changed = true
    else
      status_changed = false
    end

    respond_to do |format|
      if @ticket.update_attributes(ticket_params)
        
        if assignee_changed && !@ticket.assignee.nil?
          TicketMailer.notify_assigned(@ticket).deliver
        elsif status_changed && !@ticket.assignee.nil?
          TicketMailer.notify_status_changed(@ticket).deliver
        end

        format.html {
          redirect_to @ticket, notice: 'Ticket was successfully updated.'
        }
        format.js {
          render notice: 'Ticket was succesfully updated.'
        }
        format.json {
          head :no_content
        }
      else
        format.html {
          render action: 'edit'
        }
        format.json {
          render json: @ticket.errors, status: :unprocessable_entity
        }
      end
    end
  end

  def create

    @ticket = TicketMailer.receive(params[:message])

    respond_to do |format|
      format.json { render json: @ticket, status: :created }
    end
  end

  private
    def ticket_params
      params.require(:ticket).permit(
          :content, 
          :user_id,
          :subject,
          :status_id,
          :assignee_id,
          :priority_id,
          :message_id)
    end
end
