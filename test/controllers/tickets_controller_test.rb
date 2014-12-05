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

  teardown do
    I18n.locale = :en
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

  test 'should get new as anonymous' do
    get :new
    assert_response :success
  end

  test 'should create ticket when posted from MTA' do

    # should ignore this in emails, but use application default
    I18n.locale = :nl

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do

        post :create, message: @simple_email, format: :json

        assert_response :success
      end
    end

    # should have used English locale
    assert_match 'View new ticket', ActionMailer::Base.deliveries.last.html_part.body.decoded

    refute_equal 0, assigns(:ticket).notified_users.count

  end

  test 'should not create ticket when invalid' do

    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      assert_no_difference 'Ticket.count' do
        post :create, ticket: {
            from: '',
            content: '',
            subject: '',
        }

        assert_response :success
      end
    end

    assert_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should create ticket when not signed in' do

    assert_difference 'ActionMailer::Base.deliveries.size', User.agents.count do
      assert_difference 'Ticket.count' do
        post :create, ticket: {
            from: 'test@test.nl',
            content: @ticket.content,
            subject: @ticket.subject,
        }

        assert_response :success
      end
    end

    refute_equal 0, assigns(:ticket).notified_users.count
  end

  test 'should create ticket when signed in' do
    sign_in users(:alice)

    assert_difference 'ActionMailer::Base.deliveries.size' do
      assert_difference 'Ticket.count', 1 do
        post :create, ticket: {
            from: 'test@test.nl',
            content: @ticket.content,
            subject: @ticket.subject,
        }

        assert_redirected_to ticket_url(assigns(:ticket))
      end

      refute_equal 0, assigns(:ticket).notified_users.count
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

  test 'should get csv index' do
    sign_in users(:alice)

    get :index, format: :csv
    assert_response :success
    assert_not_nil assigns(:tickets)
  end

  test 'should show ticket' do
    sign_in users(:alice)

    get :show, id: @ticket.id
    assert_response :success

    # should contain this for label adding with javascript
    assert_select '[data-labelings]'

    # should contain this for label removing with javascript
    assert_select '[data-labeling-id=?]',
        @ticket.labelings.first.id

    # should contain this anchor for linking from notification email
    assert_select '[id=reply-' + @ticket.replies.first.id.to_s + ']'
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

  test 'should not show duplicate tickets to agents' do
    sign_in users(:alice)

    @ticket.labels.create!(name: 'test1')
    @ticket.labels.create!(name: 'test2')

    get :index
    assert_response :success

    tickets = assigns(:tickets)
    assert_equal tickets.pluck(:id).uniq, tickets.pluck(:id)

  end

  test 'should not show duplicate tickets to customers' do
    charlie = users(:charlie)
    sign_in charlie

    label = @ticket.labels.create!(name: 'test1')
    charlie.labels << label

    label = @ticket.labels.create!(name: 'test2')
    charlie.labels << label

    get :index
    assert_response :success

    tickets = assigns(:tickets)
    assert_equal tickets.pluck(:id).uniq, tickets.pluck(:id)

  end

  test 'should allow CORS' do
    [:new, :create].each do |action|
      process(action, 'OPTIONS')

      assert_response :ok
      assert_equal '*', response.headers['Access-Control-Allow-Origin']
      assert_equal 'GET,POST', response.headers['Access-Control-Allow-Methods']
      assert_equal 'Origin,Accept,Content-Type,X-Requested-With,X-CSRF-Token', 
          response.headers['Access-Control-Allow-Headers']
    end
  end

end
