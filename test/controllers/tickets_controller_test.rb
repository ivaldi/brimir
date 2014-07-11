# Brimir is a helpdesk system to handle email support requests.
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

class TicketsControllerTest < ActionController::TestCase

  setup do

    @ticket = tickets(:problem)


    # read_fixture doesn't work in ActionController::TestCase, so use File.new
    @simple_email = File.new('test/fixtures/ticket_mailer/simple').read
  end

  test 'should get new as customer' do

    sign_in users(:bob) # customer sign in

    get :new
    assert_response :success
  end

  test 'should get new as agent' do
    sign_in users(:alice)

    get :new
    assert_response :success
  end

  test 'should create ticket when posted from MTA' do

    assert_difference 'Ticket.count', 1 do
      post :create, message: @simple_email, format: :json

      assert_response :success
    end

  end

  test 'should create ticket from html form' do
    assert_difference 'Ticket.count', 1 do
      post :create, ticket: {
          from: 'test@test.nl',
          content: @ticket.content,
          subject: @ticket.subject
      }

      assert_redirected_to ticket_url(assigns(:ticket))
    end
  end

  test 'should only allow agents to view others tickets' do
    sign_in users(:bob)

    get :show, id: tickets(:multiple)
    assert_response :unauthorized # redirect to sign in page
  end

  test 'should get index' do
    sign_in users(:alice)

    get :index
    assert_response :success
    assert_not_nil assigns(:tickets)
  end

  test 'should show ticket' do
    sign_in users(:alice)

    get :show, id: @ticket.id
    assert_response :success
  end

  test 'should email assignee if ticket is assigned by somebody else' do
    sign_in users(:alice)
    
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
    sign_in users(:charlie)
    
    # assignee should receive notification
    assert_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { status: 'closed' }
      assert_redirected_to ticket_path(@ticket)

    end

    # currently we can check whether the hardcoded word status is in the body
    # in the future we might use templates or translations...
    assert_match 'status', ActionMailer::Base.deliveries.last.body.decoded
  end

  test 'should email assignee if priority of ticket is changed by somebody else' do
    sign_in users(:charlie)

    # assignee should receive notification
    assert_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { priority: 'high' }
      assert_redirected_to ticket_path(@ticket)

    end

    # currently we can check whether the hardcoded word priority is in the body
    # in the future we might use templates or translations...
    assert_match 'priority', ActionMailer::Base.deliveries.last.body.decoded

  end

  test 'should not email assignee if ticket is assigned by himself' do
    sign_in users(:charlie)

    # new assignee should not receive notification
    assert_no_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { assignee_id: users(:charlie).id }
      assert_redirected_to ticket_path(@ticket)

    end

  end

  test 'should not email assignee if status of ticket is changed by himself' do
    sign_in users(:alice)

    # assignee should not receive notification
    assert_no_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { status: 'closed' }
      assert_redirected_to ticket_path(@ticket)

    end

  end

  test 'should not email assignee if priority of ticket is changed by himself' do
    sign_in users(:alice)

    # assignee should not receive notification
    assert_no_difference 'ActionMailer::Base.deliveries.size' do

      put :update, id: @ticket.id, ticket: { priority: 'high' }
      assert_redirected_to ticket_path(@ticket)

    end

  end
  
  test 'should not show other ticket to subagent' do
    sign_in users(:dave)

    get :show, id: tickets(:problem)
    assert_response :unauthorized
  end

  test 'should show ticket to subagent' do
    sign_in users(:dave)

    get :show, id: tickets(:multiple)
    assert_response :success
  end

end
