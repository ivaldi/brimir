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

module CreateFromUser
  extend ActiveSupport::Concern

  included do
    attr_accessor :from

    def from=(email)

      # search using the same method as Devise validation
      from_user = User.find_first_by_auth_conditions(email: email)

      if !from_user
        password_length = 12
        password = Devise.friendly_token.first(password_length)
        from_user = User.create!(email: email, password: password,
            password_confirmation: password)
      end

      self.user = from_user

    end

    def from
      user.email unless user.nil?
    end
  end

end
