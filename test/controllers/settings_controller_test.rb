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

class SettingsControllerTest < ActionController::TestCase

  setup do

    @tenant = tenants(:main)
  end

  teardown do
    I18n.locale = :en
  end

  test 'should create e-mailtemplates' do
    sign_in users(:alice)

    # make sure there are now templates
    EmailTemplate.delete_all

    if EmailTemplate.count == 0
      assert_difference 'EmailTemplate.count', 2 do
        put :update, params: {
          id: @tenant.id, tenant: {
          notify_user_when_account_is_created: true,
          notify_client_when_ticket_is_created: true
          }
        }
      end
    end
  end

end
