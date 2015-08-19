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

module Tickets
  class LocksController < ApplicationController
    skip_authorization_check only: [:create, :destroy]

    def create
      @ticket = Ticket.find(params[:ticket_id])
      if can? :update, @ticket
        @ticket.locked_by = current_user
        @ticket.locked_at = Time.zone.now
        @ticket.save
      end
    end

    def destroy
      @ticket = Ticket.find(params[:ticket_id])
      # if labels can be removed by this user,
      # he can also unlock tickets, because he is not limited
      if can?(:destroy, Labeling.new(labelable: @ticket))
        @ticket.locked_by = nil
        @ticket.locked_at = nil
        @ticket.save
      end
      redirect_to ticket_path(@ticket)
    end
  end
end
