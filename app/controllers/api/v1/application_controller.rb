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

class Api::V1::ApplicationController < ActionController::Base
  include MultiTenancy
  
  protect_from_forgery with: :null_session

  before_action :authenticate_user_from_token!

  check_authorization

  def authenticate_user_from_token!
    user_token = params[:auth_token].presence
    user = user_token && User.where(authentication_token: user_token.to_s).first

    if user && Devise.secure_compare(user.authentication_token, params[:auth_token])
      sign_in user, store: false
    else
      render nothing: true, status: :unauthorized
    end
  end
end
