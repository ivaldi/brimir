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
class Api::V1::UsersController < Api::V1::ApplicationController
  include UsersStrongParams
  load_and_authorize_resource :user

  def create
    @user = User.new(user_params)
    if @user.save
      render nothing: true, status: :created
    else
      render nothing: true, status: :bad_request
    end
  end

  def show
    unless @user = User.find_by(email: Base64.urlsafe_decode64(params[:email]))
      render nothing: true, status: :bad_request
    end
  end
end