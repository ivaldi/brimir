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

require 'test_helper'

module Tickets
  # tests for interaction with deleted tickets
  class DeletedControllerTest < ActionController::TestCase

    setup do
      sign_in users(:alice)
    end

    test 'should empty trash' do

      Ticket.update_all(status: Ticket.statuses[:deleted])

      assert_difference 'Ticket.count', -3 do
        delete :destroy
        assert_redirected_to tickets_url(status: :deleted)
      end
    end
  end
end
