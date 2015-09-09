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

class RepliesController < ApplicationController

  load_and_authorize_resource :reply, except: [:create]

  def create
    # store attributes and reopen ticket
    @reply = current_user.replies.new({
        'ticket_attributes' => {
            'status' => 'open',
            'id' => reply_params[:ticket_id]
          }
        }.merge(reply_params))

    authorize! :create, @reply

    save_reply_and_redirect
  end

  def update
    @reply.assign_attributes(reply_params)
    save_reply_and_redirect
  end

  def show
    respond_to do |format|
      format.eml do
        begin
          send_file @reply.raw_message.path(:original),
              filename: "reply-#{@reply.id}.eml",
              type: 'text/plain',
              disposition: :attachment
        rescue
          raise ActiveRecord::RecordNotFound
        end
      end
    end
  end

  protected

  def save_reply_and_redirect
    begin
      if @reply.draft?
        original_updated_at = @reply.ticket.updated_at

        @reply.save

        # don't screw up the ordering of inbox by resetting updated_at
        @reply.ticket.update_column :updated_at, original_updated_at

        redirect_to @reply.ticket, notice: I18n::translate(:draft_saved)
      else
        Reply.transaction do
          @reply.save!

          @reply.notified_users.each do |user|
            mail = if Tenant.current_tenant.include_conversation_in_replies?
              @ticket = @reply.ticket
              @replies = @reply.ticket.replies.reverse.select do |reply| 
                # Here, we have to decide which replies to include in the conversation
                # that is sent to the client.
                # 
                #   1. Do not include internal notes without recipient.
                #   2. Do not include internal questions to other agents.
                #   3. Do not include internal response from other agents.
                #   4. Include all replies that have the user as recipient.
                #   5. Include all external replies from the user.
                #   6. Incldue all external replies from other users, since
                #       a. clients tend to reply from different email addresses, and
                #       b. we often need confirmations from other external staff like
                #            "I confirm that you may grant this person admin permissions."
                #
                reply.notified_users.include?(user) or  # 1., 2., 3., 4.
                reply.user == user or                   # 1., 2., 3.,     5.
                !reply.user.agent?                      # 1., 2., 3.,         6.
              end
              NotificationMailer.new_reply_with_conversation(@replies, @ticket, user)
            else
              NotificationMailer.new_reply(@reply, user)
            end

            mail.deliver_now unless EmailAddress.pluck(:email).include?(user.email)
            @reply.message_id = mail.message_id
          end

          @reply.save!
        end

        redirect_to @reply.ticket, notice: I18n::translate(:reply_added)
      end
    rescue => e
      Rails.logger.error 'Exception occured on Reply transaction!'
      Rails.logger.error "Message: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.join("\n")}"
      @outgoing_addresses = EmailAddress.verified.ordered
      render action: 'new'
    end
  end

  def reply_params
    attributes = params.require(:reply).permit(
        :content,
        :ticket_id,
        :message_id,
        :user_id,
        :content_type,
        :draft,
        notified_user_ids: [],
        attachments_attributes: [
          :file
        ],
        ticket_attributes: [
          :id,
          :to_email_address_id,
          :status,
        ]
    )

    unless can?(:update, Ticket.find(attributes[:ticket_id]))
      attributes.delete(:ticket_attributes)
    end

    attributes
  end

end
