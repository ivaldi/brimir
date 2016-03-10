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

  test 'should notify label users' do
    ticket = Ticket.new from: 'test@test.com', content: 'test'
    ticket.labels << labels(:bug)

    reply = ticket.replies.new
    reply.set_default_notifications!

    assert reply.notified_users.include?(users(:dave))
  end

  test 'should reply to all agents if not assigned' do
    Tenant.current_domain = tenants(:main).domain
    Tenant.current_tenant.first_reply_ignores_notified_agents = true

    ticket = tickets(:daves_problem)
    reply = ticket.replies.new
    reply.set_default_notifications!

    assert reply.notified_users.include?(users(:alice))
    assert reply.notified_users.include?(users(:charlie))
  end

  test 'should not reply to all agents if assigned' do
    Tenant.current_domain = tenants(:main).domain
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
  end

  test 'should reply to agent if assigned' do
    Tenant.current_domain = tenants(:main).domain
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

end
