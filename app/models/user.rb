# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi http://ivaldi.nl
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

class User < ActiveRecord::Base
  # Returns the auth strategy to use with Devise. Possible return values are
  # :database_authenticatable, :ldap_authenticatable. If you choose
  # :ldap_authenticatable, make sure to update config/ldap.yml with correct values.
  # You may also want to make this dynamic:
  #
  #   def self.authentication_strategy
  #     Rails.env.production? ? :ldap_authenticatable : :database_authenticatable
  #   end
  #
  def self.authentication_strategy
    :database_authenticatable
  end

  devise authentication_strategy, :recoverable, :rememberable, :trackable, :validatable,
    :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :tickets, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :labelings, as: :labelable, dependent: :destroy
  has_many :labels, through: :labelings

  # identities for omniauth
  has_many :identities

  # All ldap users are agents by default, remove/comment this method if this
  # is not the intended behavior.
  def ldap_before_save
    self.agent = true
  end

  scope :agents, -> {
    where(agent: true)
  }

  scope :ordered, -> {
    order(:email)
  }

  scope :by_email, ->(email) {
    where('LOWER(email) LIKE ?', '%' + email.downcase + '%')
  }

  def self.agents_to_notify
    User.agents
        .where(notify: true)
  end
end
