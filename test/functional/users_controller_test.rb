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

  setup do
    sign_in users(:alice)
    @user = users(:alice)
  end

  test 'should get edit' do
    get :edit, id: @user.id
    assert_response :success
  end

  test 'should modify signature' do
    put :update, id: @user.id, user: { signature: 'Alice' }
    assert_equal 'Alice', assigns(:user).signature
    assert_redirected_to tickets_url
  end
end
