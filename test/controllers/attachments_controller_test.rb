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

class AttachmentsControllerTest < ActionController::TestCase

  setup do
    sign_in users(:alice)
    @attachment = attachments(:default_page)
    @attachment.update_attributes!({
      file: fixture_file_upload('attachments/default-testpage.pdf', 'application/pdf')
    })
  end

  test 'should get new' do
    sign_out users(:alice)
    xhr :get, :new
    assert_response :success
  end

  test 'should show thumb' do
    get :show, format: :thumb, id: @attachment
    assert_response :success
  end


  test 'should download original ' do
    get :show, format: :original, id: @attachment
    assert_response :success
  end

end
