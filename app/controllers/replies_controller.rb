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

  load_and_authorize_resource :reply

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

    respond_to do |format|
      if @reply.save && @reply.notify {|reply| TicketMailer.reply(reply) }
        format.html { redirect_to @reply.ticket, notice: 'Reply was successfully created.' }
        format.json { render json: @reply, status: :created, location: @reply }
        format.js { render }
      else
        format.html { render action: 'new' }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
        format.js { render }
      end
    end
  end

  private
    def reply_params
      params.require(:reply).permit(
          :content,
          :ticket_id,
          :message_id,
          :user_id,
          :to,
          :cc,
          :bcc
      )
    end

end
