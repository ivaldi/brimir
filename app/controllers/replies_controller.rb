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

    begin
      Reply.transaction do
        @reply.save!

        @reply.notified_users.each do |user|
          mail = NotificationMailer.new_reply(@reply, user)

          mail.deliver_now unless EmailAddress.pluck(:email).include?(user.email)
          @reply.message_id = mail.message_id
        end

        @reply.save!
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

  protected

  def reply_params
    attributes = params.require(:reply).permit(
        :content,
        :ticket_id,
        :message_id,
        :user_id,
        :content_type,
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
