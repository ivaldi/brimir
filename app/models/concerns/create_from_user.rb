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

module CreateFromUser
  extend ActiveSupport::Concern

  included do
    attr_accessor :from

    def from=(email)

      unless email.blank?

        # search using the same method as Devise validation
        from_user = User.find_first_by_auth_conditions(email: email)

        unless from_user
          from_user = User.where(email: email).first_or_create

          unless from_user
            errors.add(:from, :invalid)
          end
        end

        self.user = from_user
      end

    end

    def from
      user.email unless user.nil?
    end
  end

end
