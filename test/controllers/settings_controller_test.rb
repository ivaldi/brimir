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

  test 'enabled custom stylesheet set by tenant' do
    AppSettings.enable_custom_stylesheet = true
    AppSettings.custom_stylesheet_url = nil
    sign_in users(:alice)
    put :update, params: {
      id: @tenant.id, tenant: {
        stylesheet_url: '/tenant/custom.css'
      }
    }
    body = get(:edit).body
    assert_match %r(<link[^>]+href="/tenant/custom.css"), body
    assert_match %r(<input[^>]+stylesheet_url), body
    refute_match %r(<input[^>]+disabled[^>]+stylesheet_url), body
  end

  test 'enabled custom stylesheet set by app settings' do
    AppSettings.enable_custom_stylesheet = true
    AppSettings.custom_stylesheet_url = '/appsettings/custom.css'
    sign_in users(:alice)
    put :update, params: {
      id: @tenant.id, tenant: {
        stylesheet_url: '/tenant/custom.css'
      }
    }
    body = get(:edit).body
    assert_match %r(<link[^>]+href="/appsettings/custom.css"), body
    assert_match %r(<input[^>]+disabled[^>]+stylesheet_url), body
  end

  test 'disabled custom stylesheet' do
    AppSettings.enable_custom_stylesheet = false
    AppSettings.custom_stylesheet_url = '/appsettings/custom.css'
    sign_in users(:alice)
    body = get(:edit).body
    refute_match %r(<link[^>]+href="/appsettings/custom.css"), body
    refute_match %r(<input[^>]+stylesheet_url), body
  end

  test 'enabled custom javascript set by tenant' do
    AppSettings.enable_custom_javascript = true
    AppSettings.custom_javascript_url = nil
    sign_in users(:alice)
    put :update, params: {
      id: @tenant.id, tenant: {
        javascript_url: '/tenant/custom.js'
      }
    }
    body = get(:edit).body
    assert_match %r(<script[^>]+src="/tenant/custom.js"), body
    assert_match %r(<input[^>]+javascript_url), body
    refute_match %r(<input[^>]+disabled[^>]+javascript_url), body
  end

  test 'enabled custom javascript set by app settings ' do
    AppSettings.enable_custom_javascript = true
    AppSettings.custom_javascript_url = '/appsettings/custom.js'
    sign_in users(:alice)
    put :update, params: {
      id: @tenant.id, tenant: {
        javascript_url: '/tenant/custom.js'
      }
    }
    body = get(:edit).body
    assert_match %r(<script[^>]+src="/appsettings/custom.js"), body
    assert_match %r(<input[^>]+disabled[^>]+javascript_url), body
  end

  test 'disabled custom javascript' do
    AppSettings.enable_custom_javascript = false
    AppSettings.custom_javascript_url = '/appsettings/custom.js'
    sign_in users(:alice)
    body = get(:edit).body
    refute_match %r(<script[^>]+src="/appsettings/custom.js"), body
    refute_match %r(<input[^>]+javascript_url), body
  end

end
