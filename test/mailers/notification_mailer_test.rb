# Brimir is a helpdesk system that can be used to handle email support requests.
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

class NotificationMailerTest < ActionMailer::TestCase

  test 'should notify assignee of new ticket' do
    ticket = tickets(:problem)

    assert_difference 'ActionMailer::Base.deliveries.size' do
      NotificationMailer.new_ticket(ticket, User.agents.first).deliver_now
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal "<#{ticket.message_id}>", mail['Message-ID'].to_s
    assert_equal email_addresses(:brimir).formatted, mail['From'].to_s
  end

  test 'should notify user of new reply' do
    reply = replies(:solution)

    assert_difference 'ActionMailer::Base.deliveries.size' do
      NotificationMailer.new_reply(reply, User.last).deliver_now
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal "<#{reply.ticket.message_id}>", mail['In-Reply-To'].to_s
    assert_equal "<#{reply.message_id}>", mail['Message-ID'].to_s
    assert_equal email_addresses(:brimir).formatted, mail['From'].to_s
  end

  # Preventing infinite email loops
  test 'should not notify our own outgoing addresses' do
    reply = replies(:solution)
    our_email = email_addresses(:support)
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      NotificationMailer.new_reply(reply, User.new(email: our_email.email)).deliver_now
    end
  end

  test 'should notify agents of new ticket' do
    Tenant.current_domain = tenants(:main).domain
    ticket = tickets(:daves_problem)

    assert_difference 'ActionMailer::Base.deliveries.size', 2 do
      NotificationMailer.incoming_message(ticket, ticket)
    end

    first = ActionMailer::Base.deliveries.count - 2
    last = ActionMailer::Base.deliveries.count - 1
    while last >= first
      mail = ActionMailer::Base.deliveries[last]
      assert_equal "<#{ticket.message_id}>", mail['Message-ID'].to_s
      last -= 1
    end
  end

  test 'should notify agents of new reply' do
    Tenant.current_domain = tenants(:main).domain

    reply = replies(:solution)

    assert_difference 'ActionMailer::Base.deliveries.size', 2 do
      NotificationMailer.incoming_message(reply, tickets(:problem))
    end

    first = ActionMailer::Base.deliveries.count - 2
    last = ActionMailer::Base.deliveries.count - 1
    while last >= first
      mail = ActionMailer::Base.deliveries[last]
      assert_equal "<#{reply.message_id}>", mail['Message-ID'].to_s
      last -= 1
    end
  end
end
