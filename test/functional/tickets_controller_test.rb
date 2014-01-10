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

class TicketsControllerTest < ActionController::TestCase

  setup do

    @ticket = tickets(:problem)

    sign_in users(:alice)
  end

  test 'should only allow agents to view tickets' do
    sign_out users(:alice)
    sign_in users(:bob)
    get :index
    assert_response :redirect  # redirect to sign in page
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:tickets)
  end

  test 'should email assignee if ticket is assigned by somebody else' do
    
    # new assignee should receive notification
    assert_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { assignee_id: users(:charlie).id }
      assert_redirected_to ticket_path(@ticket)

    end

    # currently we can check whether the hardcoded word assigned is in the body
    # in the future we might use templates or translations...
    assert_match 'assigned', ActionMailer::Base.deliveries.last.body.decoded
  end

  test 'should email assignee if status of ticket is changed by somebody else' do
    sign_out users(:alice)
    sign_in users(:charlie)
    
    # assignee should receive notification
    assert_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { status_id: statuses(:closed).id }
      assert_redirected_to ticket_path(@ticket)

    end

    # currently we can check whether the hardcoded word status is in the body
    # in the future we might use templates or translations...
    assert_match 'status', ActionMailer::Base.deliveries.last.body.decoded
  end

  test 'should email assignee if priority of ticket is changed by somebody else' do
    sign_out users(:alice)
    sign_in users(:charlie)

    # assignee should receive notification
    assert_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { priority_id: priorities(:high).id }
      assert_redirected_to ticket_path(@ticket)

    end

    # currently we can check whether the hardcoded word priority is in the body
    # in the future we might use templates or translations...
    assert_match 'priority', ActionMailer::Base.deliveries.last.body.decoded

  end

  test 'should not email assignee if ticket is assigned by himself' do
    sign_out users(:alice)
    sign_in users(:charlie)

    # new assignee should not receive notification
    assert_no_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { assignee_id: users(:charlie).id }
      assert_redirected_to ticket_path(@ticket)

    end

  end

  test 'should not email assignee if status of ticket is changed by himself' do

    # assignee should not receive notification
    assert_no_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { status_id: statuses(:closed).id }
      assert_redirected_to ticket_path(@ticket)

    end

  end

  test 'should not email assignee if priority of ticket is changed by himself' do

    # assignee should not receive notification
    assert_no_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { priority_id: priorities(:high).id }
      assert_redirected_to ticket_path(@ticket)

    end

  end

end
