# Brimir is a helpdesk system to handle email support requests.
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

class Api::V1::TicketsControllerTest < ActionController::TestCase

  setup do
    @ticket = tickets(:problem)
  end

  test 'should get index' do
    sign_in users(:bob)

    get :index, auth_token: users(:bob).authentication_token, :format => :json
    assert_response :success
    assert_not_nil assigns(:tickets)
  end

  test 'should show ticket' do
    sign_in users(:bob)

    get :show, auth_token: users(:bob).authentication_token, id: @ticket.id, :format => :json
    assert_response :success
  end

  test 'should create ticket' do
    sign_in users(:bob)
    assert_difference 'Ticket.count', 1 do
      post :create, auth_token: users(:bob).authentication_token, ticket: {
        content: 'I need help',
        from: 'bob@xxxx.com',
        subject: 'Remote from API',
        priority: 'low'}, 
        format: :json
    end
    assert_response :success
  end

end
