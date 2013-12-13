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
    @statuses = Status.filters

    @priorities = Priority.all

    @active_status = Status.find_by_id_from_filters(params[:status_id])
    @tickets = @active_status
      .tickets
      .search(params[:q])
      .filter_by_assignee_id(params[:assignee_id])
      .page(params[:page])
      .order(:created_at)

  end

  def update
    @ticket = Ticket.find(params[:id])

    respond_to do |format|
      if @ticket.update_attributes(ticket_params)
        
        if !@ticket.assignee.nil?

          if @ticket.previous_changes.include? :assignee_id
            TicketMailer.notify_assigned(@ticket).deliver

          elsif @ticket.previous_changes.include? :status_id
            TicketMailer.notify_status_changed(@ticket).deliver

          elsif @ticket.previous_changes.include? :priority_id
            TicketMailer.notify_priority_changed(@ticket).deliver
          end

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
