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

class User < ActiveRecord::Base
  devise Rails.application.config.devise_authentication_strategy, :recoverable,
    :rememberable, :trackable, :validatable,:omniauthable,
    omniauth_providers: [:google_oauth2]

  has_many :tickets, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :labelings, as: :labelable, dependent: :destroy
  has_many :labels, through: :labelings
  has_many :assigned_tickets, class_name: 'Ticket',
      foreign_key: 'assignee_id', dependent: :nullify
  has_many :notifications, dependent: :destroy

  # identities for omniauth
  has_many :identities

  has_and_belongs_to_many :unread_tickets, class_name: 'Ticket', join_table: 'user_tickets'

  after_initialize :default_localization
  before_validation :generate_password

  # All ldap users are agents by default, remove/comment this method if this
  # is not the intended behavior.
  def ldap_before_save
    self.agent = true
  end

  scope :agents, -> {
    where(agent: true)
  }

  scope :by_agent, ->(value) {
    where(agent: value)
  }

  scope :ordered, -> {
    order(:email)
  }

  scope :by_email, ->(email) {
    where('LOWER(email) LIKE ?', '%' + email.downcase + '%')
  }

  scope :search, ->(term) {
    if !term.nil?
      term.gsub!(/[\\%_]/) { |m| "!#{m}" }
      term = "%#{term.downcase}%"
      where('LOWER(email) LIKE ? ESCAPE ?', term, '!')
    end
  }

  def name
    super || name_from_email_address
  end

  def name_from_email_address
    email.split('@').first
  end

  def self.agents_to_notify
    User.agents
        .where(notify: true)
  end

  # Does the email address of this user belong to the ticket system
  # itself? For example, there might be a user corresponding to
  # support@example.com.
  #
  # This check is needed to prevent email loops. We do not want to
  # deliver to those email addresses, since they would be received
  # by the ticket system, again, creating an email loop.
  #
  def ticket_system_address?
    User.ticket_system_addresses.pluck(:id).include? self.id
  end

  # Return all users that correspond to email addresses belonging
  # to the ticket system, e.g. support@example.com.
  #
  def self.ticket_system_addresses
    User.where(email: EmailAddress.pluck(:email))
  end

  def client?
    not agent?
  end

  def default_localization
    self.time_zone = Tenant.current_tenant.default_time_zone if time_zone.blank?
    self.locale = Tenant.current_tenant.default_locale if locale.blank?
  end

  def generate_password
    if encrypted_password.blank?
      self.password = Devise.friendly_token.first(12)
    end
  end
end
