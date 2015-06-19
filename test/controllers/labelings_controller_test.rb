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

class LabelingsControllerTest < ActionController::TestCase

  setup do
    @labeling = labelings(:bug_ticket)

    sign_in users(:alice)
  end

  test 'should create labeling' do

    assert_difference 'Labeling.count' do

      post :create, format: :js, labeling: {
        labelable_id: tickets(:problem).id,
        labelable_type: 'Ticket',
        label: {
          name: 'Hello'
        }
      }

      assert_response :success
    end
  end

  test 'should remove labeling' do
    assert_difference 'Labeling.count', -1 do
      delete :destroy, id: @labeling, format: :js

      assert_response :success
    end
  end

  test 'should show labels in sidebar' do
    
  end

end
