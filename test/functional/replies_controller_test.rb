# Brimir is a helpdesk system to handle email support requests.
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

class RepliesControllerTest < ActionController::TestCase

  setup do

    @ticket = tickets(:problem)
    @reply = replies(:solution)

    sign_in users(:alice)
  end

  test 'should send reply when reply is added' do

    # do we send a mail
    assert_difference 'ActionMailer::Base.deliveries.size' do
      post :create, reply: { content: @reply.content, ticket_id: @ticket.id }
    end

    assert_match @reply.content, ActionMailer::Base.deliveries.last.body.decoded

  end

  test 'reply should always contain text' do

    # no emails should be send when invalid reply
    assert_no_difference 'ActionMailer::Base.deliveries.size' do      
      post :create, reply: { content: '', ticket_id: @ticket.id }
    end

    refute_equal 0, assigns(:reply).errors.size

  end

  test 'reply should contain signature' do

    post :create, reply: { content: @reply.content, ticket_id: @ticket.id }

    assert_match assigns(:reply).user.signature, 
        ActionMailer::Base.deliveries.last.body.decoded

  end


end
