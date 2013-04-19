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
    assert_match(/From:/, @simple_email)
  end

  test "new email from unkown user is stored" do
    
    assert_difference "Ticket.count" do 

      assert_difference "User.count" do 

        TicketMailer.receive(@simple_email)

      end
      
    end

    # TODO check whether agents receive mail

  end

  test "email threads are recognized correctly" do

    thread_start = read_fixture('thread_start').join
    thread_reply = read_fixture('thread_reply').join

    assert_difference "Ticket.count" do 
      assert_difference "User.count" do 
        TicketMailer.receive(thread_start)
      end
    end

    assert_difference "Reply.count" do 
      assert_difference "User.count", 0 do 
        TicketMailer.receive(thread_reply)
      end
    end

  end

  test "email with attachments work" do

    attachments = read_fixture('attachments').join
    assert_difference "Ticket.count" do 
      assert_difference "Attachment.count", 2 do 
        TicketMailer.receive(attachments)
      end
    end
  
  end
end
