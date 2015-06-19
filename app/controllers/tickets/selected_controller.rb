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

module Tickets
  # class to interact with all selected tickets (params[:id][...])
  class SelectedController < ApplicationController
    skip_load_and_authorize_resource

    def update
      @tickets = Ticket.where(id: params[:id])

      @tickets.each do |ticket|
        authorize! :update, ticket
        ticket.update_attributes(ticket_params)
      end

      redirect_to tickets_url, notice: t(:tickets_status_modified)
    end

    protected

    def ticket_params
      params.require(:ticket).permit(:status)
    end
  end
end

