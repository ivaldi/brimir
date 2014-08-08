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

    if @reply.save && @reply.notify do |reply|
      NotificationMailer.new_reply(current_user, reply)
    end
      redirect_to @reply.ticket, notice: I18n::translate(:reply_added)
    else
      render action: 'new'
    end
  end

  private
    def reply_params

      if current_user.agent?

        # only agents are allowed to sent to any address they like
        # (to, cc, bcc)
        params.require(:reply).permit(
            :content,
            :ticket_id,
            :message_id,
            :user_id,
            :to,
            :cc,
            :bcc
        )
      else
        params.require(:reply).permit(
            :content,
            :ticket_id,
            :message_id,
            :user_id,
        )
      end
    end

end
