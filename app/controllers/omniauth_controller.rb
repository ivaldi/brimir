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

class OmniauthController < Devise::OmniauthCallbacksController

  def google_oauth2
    auth = request.env['omniauth.auth']

    @identity = Identity.find_with_omniauth(auth)

    if @identity.nil?
      @identity = Identity.create_with_omniauth(auth)
    end

    if signed_in?
      if @identity.user == current_user
        redirect_to root_url, notice: I18n.translate(:already_linked_accounts)
      else
        # the identity is not associated with the current_user so lets
        # associate the identity
        @identity.user = current_user
        @identity.save
        redirect_to root_url, notice: I18n.translate(:successfully_linked_account)
      end
    else
      if @identity.user.present?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
        sign_in_and_redirect @identity.user, event: :authentication
      else
        # no user associated with the identity so we reject this attemp
        redirect_to new_user_session_path, alert: I18n.translate(:not_linked_account_cant_login)
      end
    end
  end

  def failure
    redirect_to root_url, alert: I18n.translate(:third_party_failure)
  end

  protected
    def auth_hash
      request.env['omniauth.auth']
    end
end
