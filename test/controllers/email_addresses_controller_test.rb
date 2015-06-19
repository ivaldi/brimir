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

class EmailAddressesControllerTest < ActionController::TestCase

  setup do
    @alice = users(:alice)
    @bob = users(:bob)
    @email_address = email_addresses(:support)
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

  test 'should get new' do
    sign_in @alice

    get :new
    assert_response :success
  end

  test 'should create' do
    sign_in @alice

    assert_difference 'ActionMailer::Base.deliveries.size' do
      assert_no_difference 'EmailAddress.where(default: true).count' do
        assert_difference 'EmailAddress.count' do
          post :create, email_address: { email: 'support@support.bla', default: '1' }
        end
      end
    end

    assert_redirected_to email_addresses_url
    assert_equal assigns(:email_address).verification_token,
        ActionMailer::Base.deliveries.last['X-Brimir-Verification'].to_s
  end

  test 'should destroy' do
    sign_in @alice

    assert_difference 'EmailAddress.count', -1 do
      delete :destroy, id: @email_address.id
    end

    assert_redirected_to email_addresses_url
  end
end
