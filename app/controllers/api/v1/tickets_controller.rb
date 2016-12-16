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
class Api::V1::TicketsController < Api::V1::ApplicationController
  include TicketsStrongParams

  load_and_authorize_resource :ticket

  def index
    if current_user.agent && params.has_key?(:user_email)
      user = User.find_by( email: Base64.urlsafe_decode64(params[:user_email]) )
      @tickets = Ticket.by_status(:open).viewable_by(user)
    else
      @tickets = Ticket.by_status(:open).viewable_by(current_user)
    end
  end

  def show
    @ticket = Ticket.find(params[:id])
  end

  def create
    @ticket = Ticket.new(ticket_params)
    if @ticket.save
      NotificationMailer.incoming_message(@ticket, params[:message])
      head :created
    else
      head :bad_request
    end
  end
end
