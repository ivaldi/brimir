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

class StatusTest < ActiveSupport::TestCase
  setup do
    @default_status = statuses(:open)
  end

  test "should include the All status" do
    assert_includes Status.filters, Status.all_status
  end

  test "should return all tickets within the All status" do
    assert_equal Ticket.count, Status.all_status.tickets.count
  end

  test "finding an id of nil should return the default status" do
    assert_equal @default_status, Status.find_by_id_from_filters(nil)
  end

  test "finding an id of 0 should return the All status" do
    assert_equal Status.all_status, Status.find_by_id_from_filters(0)
  end
end

