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

class ReplyTest < ActiveSupport::TestCase

  setup do
    Tenant.current_domain = tenants(:main).domain
  end

  test 'should notify label users' do
    ticket = Ticket.new from: 'test@test.com', content: 'test'
    ticket.labels << labels(:bug)

    reply = ticket.replies.new
    reply.set_default_notifications!

    assert reply.notified_users.include?(users(:dave))
  end

  test 'should reply to all agents if not assigned' do
    Tenant.current_tenant.first_reply_ignores_notified_agents = true

    ticket = tickets(:daves_problem)
    reply = ticket.replies.new
    reply.set_default_notifications!

    assert reply.notified_users.include?(users(:alice))
    assert reply.notified_users.include?(users(:charlie))
  end

  test 'should not reply to all agents if assigned' do
    Tenant.current_tenant.first_reply_ignores_notified_agents = true

    ticket = tickets(:daves_problem)
    ticket.assignee = users(:alice)
    ticket.save
    reply = ticket.replies.new
    reply.user = users(:alice)
    reply.reply_to = ticket
    reply.set_default_notifications!

    refute reply.notified_users.include?(users(:alice))
    refute reply.notified_users.include?(users(:charlie))
    assert reply.notified_users.include?(users(:dave))
    assert reply.notified_users.include?(users(:bob)) # was CC-ed by Dave
  end

  test 'should reply to agent if assigned' do
    Tenant.current_tenant.first_reply_ignores_notified_agents = false

    ticket = tickets(:daves_problem)
    ticket.assignee = users(:alice)
    ticket.save
    reply = ticket.replies.new
    reply.user = users(:alice)
    reply.reply_to = ticket
    reply.set_default_notifications!

    refute reply.notified_users.include?(users(:alice))
    assert reply.notified_users.include?(users(:charlie))
  end

  test 'should not notify other clients when one of the clients replies' do
    #
    # Suppose, several clients are part of a conversation. Now, one of the
    # clients replies to something an agent wrote and only answers to the
    # email address of the ticket system, e.g. support@example.com.
    #
    # The other clients that are part of this conversation should not be
    # notified, since the sender can't see that they would receive this
    # email.
    #
    # See also: https://github.com/ivaldi/brimir/issues/259
    #
    agent = User.create! email: 'agent@example.com', agent: true
    client1 = User.create! email: 'client1@example.com'
    client2 = User.create! email: 'client2@example.com'

    # client1 creates a ticket via email.
    ticket = Ticket.create from: 'client1@example.com', content: 'This is my problem'

    # agent replies via the web ui of brimir.
    reply_of_the_agent = ticket.replies.create! content: 'This might be the solution. It did work for client2 who also works in your office.', user: agent
    reply_of_the_agent.notified_users << client1
    reply_of_the_agent.notified_users << client2

    # client1 replies via email; cc to client2.
    reply_of_client1 = ticket.replies.create! content: 'It did not work.', user: client1
    reply_of_client1.reply_to = reply_of_the_agent
    reply_of_client1.set_default_notifications!("From: client1@example.com\nTo: ...")
    reply_of_client1.notified_users << client2 unless reply_of_client1.notified_users.include? client2

    assert reply_of_client1.notified_users.include?(agent)
    assert reply_of_client1.notified_users.include?(client2)

    # client2 replies via email, but not cc to client1.
    reply_of_client2 = ticket.replies.create! content: 'client1 is stupid! Did he even start his computer?', user: client2
    reply_of_client2.reply_to = reply_of_the_agent
    reply_of_client2.set_default_notifications!("From: client2@example.com\nTo: ...")

    assert reply_of_client2.notified_users.include?(agent)
    assert not(reply_of_client2.notified_users.include?(client1))
  end

  test 'should sync the message ids of notifications' do
    ticket = tickets(:daves_problem)
    reply = ticket.replies.create user: users(:alice), content: "This is the solution."
    reply.notified_users << users(:dave)
    reply.notified_users << users(:bob)

    message_ids = reply.notification_mails.map(&:message_id)
    assert_equal message_ids.count,  2
    assert_equal message_ids.uniq.count, 1
    refute_equal message_ids.first, ""
    refute_equal message_ids.first, nil
  end

end
