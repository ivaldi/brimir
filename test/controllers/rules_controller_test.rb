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

class RulesControllerTest < ActionController::TestCase

  setup do
    @alice = users(:alice)
    @bob = users(:bob)

    @rule = rules(:assign_when_ivaldi)
  end

  test 'should get index' do
    sign_in @alice

    get :index
    assert_response :success
  end

  test 'should not get index' do
    sign_in @bob

    get :index
    assert_response :unauthorized
  end

  test 'should get edit' do
    sign_in @alice

    get :edit, id: @rule
    assert_response :success
  end

  test 'should update' do
    sign_in @alice

    put :update, id: @rule, rule: {
        filter_field: 'subject',
    }
    assert_equal 'subject', assigns(:rule).filter_field
    assert_redirected_to rules_url
  end

  test 'should get new' do
    sign_in @alice

    get :new
    assert_response :success
  end

  test 'should create' do
    sign_in @alice

    assert_difference 'Rule.count' do
      post :create, rule: {
        filter_field: @rule.filter_field,
        filter_operation: @rule.filter_operation,
        filter_value: @rule.filter_value,
        action_operation: @rule.action_operation,
        action_value: @rule.action_value,
      }

      assert_redirected_to rules_url
    end
  end

  test 'should remove rule' do
    sign_in @alice

    assert_difference 'Rule.count', -1 do
      delete :destroy, id: @rule

      assert_redirected_to rules_url
    end

  end

end
