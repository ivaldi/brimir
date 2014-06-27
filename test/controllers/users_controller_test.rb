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

class UsersControllerTest < ActionController::TestCase

  test 'should get edit' do
    alice = users(:alice)
    sign_in alice

    get :edit, id: alice.id
    assert_response :success
  end

  test 'should modify signature' do
    alice = users(:alice)
    sign_in alice

    put :update, id: alice.id, user: { signature: 'Alice' }
    assert_equal 'Alice', assigns(:user).signature
    assert_redirected_to users_url
  end

  test 'customer may not become agent' do
    bob = users(:bob)
    sign_in bob

    assert_no_difference 'User.agents.count' do
      put :update, id: bob.id, user: { agent: true, signature: 'Bob' }
    end
  end

  test 'customer may not create agent' do
    bob = users(:bob)
    sign_in bob

    assert_no_difference 'User.agents.count' do
      post :create, user: {
          email: 'harry@getbrimir.com',
          password: 'testtest',
          password_confirmation: 'testtest',
          agent: true,
          signature: 'Harry'
      }
    end

    assert_response :unauthorized
  end
end
