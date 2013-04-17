# Brimir is a helpdesk system that can be used to handle email support requests.
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

require 'test_helper'

class TicketMailerTest < ActionMailer::TestCase

  def setup
    @simple_email = read_fixture('simple').join
  end

  test "fixtures are loading correctly" do
    assert_match /from/i, @simple_email
  end

  test "new email from unkown user is stored" do
    
    assert_difference "Ticket.count" do 

      TicketMailer.receive(@simple_email)
      
    end

    # TODO check whether from user is added to system
    # TODO check whether agents receive mail

  end

end
