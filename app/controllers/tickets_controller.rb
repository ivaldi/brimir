# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi https://ivaldi.nl/
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
  include HtmlTextHelper
  include ActionView::Helpers::SanitizeHelper # dependency of HtmlTextHelper

  before_filter :authenticate_user!, except: [:create, :new]
  load_and_authorize_resource :ticket, except: :create
  skip_authorization_check only: :create

  # allow ticket creation using json posts
  skip_before_action :verify_authenticity_token, only: :create, if: 'request.format.json?'

  def show
    @agents = User.agents

    draft = @ticket.replies
        .where('user_id IS NULL OR user_id = ?', current_user.id)
        .where(draft: true)
        .first

    if draft.present?
      @reply = draft
    else
      @reply = @ticket.replies.new(user: current_user)
      @reply.set_default_notifications!
    end

    @labeling = Labeling.new(labelable: @ticket)

    @outgoing_addresses = EmailAddress.verified.ordered

    respond_to do |format|
      format.html
      format.eml do
        begin
          send_file @ticket.raw_message.path(:original),
              filename: "ticket-#{@ticket.id}.eml",
              type: 'text/plain',
              disposition: :attachment
        rescue
          raise ActiveRecord::RecordNotFound
        end
      end
    end
  end

  def index
    @agents = User.agents

    params[:status] ||= 'open' unless params[:user_id]

    @tickets = @tickets.by_status(params[:status])
      .search(params[:q])
      .by_label_id(params[:label_id])
      .filter_by_assignee_id(params[:assignee_id])
      .filter_by_user_id(params[:user_id])
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
            NotificationMailer.assigned(@ticket).deliver_now

          elsif @ticket.previous_changes.include? :status
            NotificationMailer.status_changed(@ticket).deliver_now

          elsif @ticket.previous_changes.include? :priority
            NotificationMailer.priority_changed(@ticket).deliver_now
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
    @ticket = Ticket.new

    unless current_user.nil?
      @ticket.user = current_user
    end

    @email_addresses = EmailAddress.verified.ordered
  end

  def create
    if params[:format] == 'json'
      @ticket = TicketMailer.receive(params[:message])
    else
      @ticket = Ticket.new(ticket_params)
    end

    if !@ticket.nil? && @ticket.save

      Rule.apply_all(@ticket) unless @ticket.is_a?(Reply)

      # where user notifications added?
      if @ticket.notified_users.count == 0
        @ticket.set_default_notifications!
      end

      # @ticket might be a Reply when via json post
      if @ticket.is_a?(Ticket)
        if @ticket.assignee.nil?
          @ticket.notified_users.each do |user|
            mail = NotificationMailer.new_ticket(@ticket, user)
            mail.deliver_now unless EmailAddress.pluck(:email).include?(user.email)
            @ticket.message_id = mail.message_id
          end

          @ticket.save
        else
          NotificationMailer.assigned(@ticket).deliver_now
        end
      end
    end

    respond_to do |format|
      format.html do

        if !@ticket.nil? && @ticket.valid?

          if current_user.nil?
            render 'create'
          else
            redirect_to ticket_url(@ticket), notice: I18n::translate(:ticket_added)
          end

        else
          @email_addresses = EmailAddress.verified.ordered
          render 'new'
        end

      end

      format.json do
        if @ticket.nil?
          render json: {}, status: :created  # bounce mail handled correctly
        elsif @ticket.valid?
          render json: @ticket, status: :created
        else
          render json: @ticket, status: :unprocessable_entity
        end
      end

      format.js { render }
    end
  end

  protected
    def ticket_params
      if !current_user.nil? && current_user.agent?
        params.require(:ticket).permit(
            :from,
            :to_email_address_id,
            :content,
            :subject,
            :status,
            :assignee_id,
            :priority,
            :message_id,
            :content_type,
            attachments_attributes: [
              :file
            ])
      else
        params.require(:ticket).permit(
            :from,
            :content,
            :subject,
            :priority,
            :content_type,
            attachments_attributes: [
              :file
            ])
      end
    end
end
