# Brimir is a helpdesk system that can be used to handle email support requests.
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

require 'test_helper'

class TicketTest < ActiveSupport::TestCase

  test 'should return accessible tickets for customer' do
    dave = users(:dave)

    tickets = Ticket.viewable_by(dave)

    assert_equal 2, tickets.count

    tickets.each do |ticket|
      assert dave == ticket.user || (ticket.label_ids & dave.label_ids).size > 0
    end
  end
end
