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

class TicketMailerTest < ActionMailer::TestCase

  def setup
    @simple_email = read_fixture('simple').join
  end

  test 'fixtures are loading correctly' do
    assert_match(/From:/, @simple_email)
  end

  test 'new email from unkown user is stored correctly' do
    # ticket is created
    assert_difference 'Ticket.count' do

      # account for user created
      assert_difference 'User.count' do

        TicketMailer.receive(@simple_email)

      end

    end
  end

  test 'email threads are recognized correctly and assignee \
      is notified' do

    thread_start = read_fixture('thread_start').join
    thread_reply = read_fixture('thread_reply').join

    # ticket created?
    assert_difference 'Ticket.count' do 
      # user created?
      assert_difference 'User.count' do 
        ticket = TicketMailer.receive(thread_start)

        # assign to first user
        ticket.assignee = User.first
        ticket.save!
      end
    end

    # agents receive notifications
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do

      # reply created?
      assert_difference 'Reply.count' do 
        # user re-used?
        assert_difference 'User.count', 0 do 
          TicketMailer.receive(thread_reply)
        end
      end
    end

  end

  test 'email with attachments work' do

    attachments = read_fixture('attachments').join
    assert_difference 'Ticket.count' do 
      assert_difference 'Attachment.count', 2 do 
        TicketMailer.receive(attachments)
      end
    end
  
  end

  test 'email with unkown reply_to' do

    unknown_reply_to = read_fixture('unknown_reply_to').join
    assert_difference 'Ticket.count' do 
      TicketMailer.receive(unknown_reply_to)
    end
  end

  test 'email with capitalized from address' do
    capitalized = read_fixture('capitalized').join
    assert_difference 'Ticket.count', 2 do 
      TicketMailer.receive(capitalized)
      TicketMailer.receive(capitalized)
    end
  end

  test 'should verify email address' do
    verification = read_fixture('verification').join
    assert_difference 'EmailAddress.where(verification_token: nil).count' do
      TicketMailer.receive(verification)
    end
  end

end
