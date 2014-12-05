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

  # this is needed for brimir integration in other sites
  before_filter :allow_cors, only: [:create, :new]

  def show
    @agents = User.agents

    @reply = @ticket.replies.new(user: current_user)
    @reply.set_default_notifications!

    @labeling = Labeling.new(labelable: @ticket)
  end

  def index
    @agents = User.agents

    params[:status] ||= 'open'

    @tickets = @tickets.by_status(params[:status])
      .search(params[:q])
      .by_label_id(params[:label_id])
      .filter_by_assignee_id(params[:assignee_id])
      .ordered

    respond_to do |format|
      format.html do
        @tickets = @tickets.paginate(page: params[:page],
            per_page: current_user.per_page)
      end
      format.csv do
        @tickets = @tickets.includes(:status_changes)
      end
    end
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
      signature = { content: '<p></p>' + current_user.signature.to_s }
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
    if params[:format] == 'json'
      @ticket = TicketMailer.receive(params[:message])
    else
      @ticket = Ticket.new(ticket_params)
    end

    if @ticket.save

      if current_user.nil?
        user = @ticket.user
      else
        user = current_user
      end

      Rule.apply_all(@ticket)

      # where user notifications added?
      if @ticket.notified_users.count == 0
        @ticket.set_default_notifications!(user)
      end

      if @ticket.assignee.nil?
        @ticket.notified_users.each do |user|
          mail = NotificationMailer.new_ticket(@ticket, user)
          mail.deliver
          @ticket.message_id = mail.message_id
        end

        @ticket.save
      else
        TicketMailer.notify_assigned(@ticket).deliver
      end
    end

    respond_to do |format|
      format.html do

        if @ticket.valid?

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
        render json: @ticket, status: :created
      end

      format.js { render }
    end
  end

  protected
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

    def allow_cors
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET,POST'
      headers['Access-Control-Allow-Headers'] =
          %w{Origin Accept Content-Type X-Requested-With X-CSRF-Token}.join(',')

      head :ok if request.request_method == 'OPTIONS'
    end

end
