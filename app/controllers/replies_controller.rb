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

class RepliesController < ApplicationController

  load_and_authorize_resource :reply, except: [:create]

  def create
    @reply = Reply.new

    if !params[:attachment].nil?

      params[:attachment].each do |file|

        @reply.attachments.new(file: file)

      end

      params[:reply].delete(:attachments_attributes)
    end

    @reply.assign_attributes(reply_params)

    @reply.user = current_user

    authorize! :create, @reply

    begin
      Reply.transaction do
        @reply.save!
        @reply.notified_users.each do |user|
          mail = NotificationMailer.new_reply(@reply, user)

          mail.deliver
          @reply.message_id = mail.message_id
        end

        @reply.save!
        redirect_to @reply.ticket, notice: I18n::translate(:reply_added)
      end
    rescue
      render action: 'new'
    end
  end

  private
    def reply_params
      params.require(:reply).permit(
          :content,
          :ticket_id,
          :message_id,
          :user_id,
          notified_user_ids: []
      )
    end

end
