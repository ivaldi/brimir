# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2016 Ivaldi https://ivaldi.nl/
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
  include TicketsStrongParams
  include ActionView::Helpers::SanitizeHelper # dependency of HtmlTextHelper

  before_action :authenticate_user!, except: [:create, :new]
  before_action :current_tenant, only: [:update, :create, :new]
  load_and_authorize_resource :ticket, except: :create
  skip_authorization_check only: :create

  # allow ticket creation using json posts
  skip_before_action :verify_authenticity_token, only: :create, if: 'request.format.json?'

  def show
    # first time seeing this ticket?
    @ticket.mark_read current_user if @ticket.is_unread? current_user

    @agents = User.agents

    draft = @ticket.replies
        .where('user_id IS NULL OR user_id = ?', current_user.id)
        .where(draft: true)
        .first

    @replies = @ticket.replies.chronologically.without_drafts.select do |reply|
      can? :show, reply
    end

    if draft.present?
      @reply = draft
    else
      @reply = @ticket.replies.new(user: current_user)
      @reply.reply_to = @replies.select{ |r| !r.internal? && !r.kind_of?(StatusReply) && !r.kind_of?(SystemReply) }.last || @ticket
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

    if params[:status] != 'merged'
      @tickets = @tickets.where.not(status: Ticket.statuses[:merged])
    end

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

        # status replies
        if @tenant.notify_client_when_ticket_is_assigned_or_closed
          if !@ticket.assignee.nil?
            if @ticket.previous_changes.include? :assignee_id
              StatusReply.create_from_assignment(@ticket, current_user).try(:notification_mails).try(:each, &:deliver_now)
            elsif @ticket.previous_changes.include? :status
              StatusReply.create_from_status_change(@ticket, current_user).try(:notification_mails).try(:each, &:deliver_now)
            end
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
    if !@tenant.ticket_creation_is_open_to_the_world? &&
          current_user.nil?
      render status: :forbidden, text: t(:access_denied)
    else
      @ticket = Ticket.new
      unless current_user.nil?
        @ticket.user = current_user
      end
      @email_addresses = EmailAddress.verified.ordered
    end
  end

  def create
    # the hook that is triggered when receiving an email.
    if params[:format] == 'json'
      using_hook = true # we assume different policies to create a ticket when we receive an email
      @ticket = TicketMailer.receive(params[:message])
      if @tenant.notify_client_when_ticket_is_created
        # we should always have a (default) template when option is selected
        template = EmailTemplate.by_kind('ticket_received').active.first
        unless template.nil?
          @reply = SystemReply.create_from_assignment(@ticket, template)
          @reply.try(:notification_mails).try(:each, &:deliver_now)
        end
      end
    else
      using_hook = false
      @ticket = Ticket.new(ticket_params)
    end

    if !@tenant.ticket_creation_is_open_to_the_world? &&
          current_user.nil? && !using_hook
      render status: :forbidden, text: t(:access_denied)
    elsif can_create_a_ticket(using_hook) && 
        (@ticket.is_a?(Reply) || @ticket.save_with_label(params[:label]))
      notify_incoming @ticket

      respond_to do |format|
        format.json { render json: @ticket, status: :created }
        format.html {
          if current_user.nil?
            flash.now[:notice] = I18n::translate(:ticket_added_public)
            render 'create'
          else
            redirect_to ticket_url(@ticket), notice: I18n::translate(:ticket_added)
          end
        }
      end
    else
      respond_to do |format|
        format.html {
          @email_addresses = EmailAddress.verified.ordered
          render 'new'
        }
        format.json {
          if @ticket.nil?
            render json: {}, status: :created  # bounce mail handled correctly
          else
            render json: @ticket, status: :unprocessable_entity
          end
        }
      end
    end
  end

  protected
  def can_create_a_ticket(using_hook)
    if @ticket.nil? || !@ticket.valid?
      flash.now[:alert] = I18n::translate(:form_validation_error)
      false
    # relax policy for requests coming from emails
    elsif using_hook
      true
    # strict policy for requests coming from the application
    else
      if Ticket.recaptcha_keys_present? && current_user.nil?
        if verify_recaptcha
          true
        else
          flash.now[:alert] = I18n::translate(:captcha_error)
          false
        end
      else
        true
      end
    end
  end

  def current_tenant
    @tenant = Tenant.current_tenant
  end

  def notify_incoming(ticket)
    NotificationMailer.incoming_message ticket, params[:message]
  end
end
