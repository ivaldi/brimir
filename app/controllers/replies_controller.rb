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

class RepliesController < ApplicationController

  # POST /replies
  # POST /replies.json
  def create
    @reply = Reply.new(params[:reply])

    @reply.user = current_user

    respond_to do |format|
      if @reply.save

        mail = TicketMailer.reply(@reply)

        mail.deliver

        # save message id for later reference
        @reply.message_id = mail.message_id
        @reply.save

        format.html { redirect_to @reply, notice: 'Reply was successfully created.' }
        format.json { render json: @reply, status: :created, location: @reply }
        format.js { render }
      else
        format.html { render action: "new" }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
        format.js { render }
      end
    end
  end

end
