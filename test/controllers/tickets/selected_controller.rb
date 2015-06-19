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

require 'test_helper'

module Tickets
  # tests for interaction with selected tickets
  class SelectedControllerTest < ActionController::TestCase

    setup do
      sign_in users(:alice)
    end

    test 'should update selected ticket status' do
      assert_equal 2, Ticket.open.count

      assert_difference 'Ticket.closed.count', 2 do
        patch :update, id: Ticket.open.pluck(:id), ticket: { status: 'closed' }
      end

      assert_equal 0, Ticket.open.count
    end
  end
end
