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

class NotificationMailerTest < ActionMailer::TestCase

  test 'should notify agent of new ticket' do
    ticket = tickets(:problem)

    assert_difference 'ActionMailer::Base.deliveries.size' do
      NotificationMailer.new_ticket(ticket, User.agents.first).deliver
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal ticket.message_id, mail.message_id

  end

  test 'should notify user of new reply' do
    reply = replies(:solution)

    assert_difference 'ActionMailer::Base.deliveries.size' do
      NotificationMailer.new_reply(reply, User.last).deliver
    end

    mail = ActionMailer::Base.deliveries.last
    assert_equal "<#{reply.ticket.message_id}>", mail['In-Reply-To'].to_s
    assert_equal reply.message_id, mail.message_id
  end

end
