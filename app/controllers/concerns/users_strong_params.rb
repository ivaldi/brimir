# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2016 Ivaldi https://ivaldi.nl/
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

module UsersStrongParams
  extend ActiveSupport::Concern
  protected
  def user_params
    attributes = params.require(:user).permit(
        :email,
        :name,
        :password,
        :password_confirmation,
        :remember_me,
        :signature,
        :agent,
        :notify,
        :time_zone,
        :locale,
        :per_page,
        :prefer_plain_text,
        :include_quote_in_reply,
        label_ids: []
    )

    # prevent normal user and limited agent from changing email and role
    if !current_user.agent? || current_user.labelings.count > 0
      attributes.delete(:email)
      attributes.delete(:agent)
      attributes.delete(:label_ids)
    end

    return attributes
  end
end