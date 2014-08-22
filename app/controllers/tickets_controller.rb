# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2014 Ivaldi http://ivaldi.nl
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

  before_filter :authenticate_user!, except: [:create, :new]
  load_and_authorize_resource :ticket, except: :create
  skip_authorization_check only: :create

  def show
    @agents = User.agents

    @reply = @ticket.replies.new(user: current_user)
    @reply.set_default_notifications!

    @labeling = Labeling.new(labelable: @ticket)
  end

  def index
    @agents = User.agents

    params[:status] ||= 'open'

    @labels = Ticket.active_labels(params[:status])
    unless current_user.agent?
      @labels = current_user.labels & @labels
    end

    @tickets = @tickets.by_status(params[:status])
      .search(params[:q])
      .by_label_id(params[:label_id])
      .filter_by_assignee_id(params[:assignee_id])
      .page(params[:page])
      .ordered
  end

  def update
    respond_to do |format|
      if @ticket.update_attributes(ticket_params)

        # assignee set and not same as user who modifies
        if !@ticket.assignee.nil? && @ticket.assignee.id != current_user.id

          if @ticket.previous_changes.include? :assignee_id
            TicketMailer.notify_assigned(@ticket).deliver

          elsif @ticket.previous_changes.include? :status
            TicketMailer.notify_status_changed(@ticket).deliver

          elsif @ticket.previous_changes.include? :priority
            TicketMailer.notify_priority_changed(@ticket).deliver
          end

        end

        format.html {
          redirect_to @ticket, notice: I18n::translate(:ticket_updated)
        }
        format.js {
          render notice: I18n::translate(:ticket_updated)
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

  def new
    unless current_user.blank?
      signature = { content: '<br /><br />' + current_user.signature.to_s }
    else
      signature = {}
    end

    unless params[:ticket].nil? # prefill params given?
      @ticket = Ticket.new(signature.merge(ticket_params))
    else
      @ticket = Ticket.new(signature)
    end

    unless current_user.nil?
      @ticket.user = current_user
    end
  end

  def create
    respond_to do |format|
      format.html do
        @ticket = Ticket.new(ticket_params)

        if current_user.nil?
          user = @ticket.user
        else
          user = current_user
        end

        if @ticket.save
          @ticket.set_default_notifications!(user)

          NotificationMailer.new_ticket(@ticket).deliver

          if current_user.nil?
            return render text: I18n::translate(:ticket_added)
          else
            redirect_to ticket_url(@ticket), notice: I18n::translate(:ticket_added)
          end
        else
          render 'new'
        end
      end
      format.json do
        @ticket = TicketMailer.receive(params[:message])
        render json: @ticket, status: :created
      end
      format.js { render }
    end
  end

  private
    def ticket_params
      if !current_user.nil? && current_user.agent?
        params.require(:ticket).permit(
            :from,
            :content,
            :subject,
            :status,
            :assignee_id,
            :priority,
            :message_id)
      else
        params.require(:ticket).permit(
            :from,
            :content,
            :subject,
            :priority)
      end
    end
end
