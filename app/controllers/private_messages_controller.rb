# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi http://ivaldi.nl
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
class PrivateMessagesController < ApplicationController
  def create
    @message = PrivateMessage.new(private_messages_params)

    @message.user = current_user

    authorize! :create, @message

    respond_to do |format|
      if @message.save
        format.html { redirect_to @message.ticket, notice: "Message Added" }
        format.json { render json: @message.to_json, response: 201 }
      end
    end
  end

  private

  def private_messages_params
    params.require(:private_message).permit(:message, :ticket_id)
  end
end
