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

class User < ActiveRecord::Base
  devise Rails.application.config.devise_authentication_strategy, :recoverable,
    :rememberable, :trackable, :validatable,:omniauthable,
    omniauth_providers: [:google_oauth2]

  has_many :tickets, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :labelings, as: :labelable, dependent: :destroy
  has_many :labels, through: :labelings

  # identities for omniauth
  has_many :identities

  after_initialize :default_localization

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
  
  def greeting
    if Time.zone.now > "4:00".to_time and Time.zone.now < "11:00".to_time
      I18n.t(:good_morning, locale: locale)
    elsif Time.zone.now > "11:00".to_time and Time.zone.now < "17:00".to_time
      I18n.t(:good_day, locale: locale)
    else
      I18n.t(:good_evening, locale: locale)
    end
  end

  def self.agents_to_notify
    User.agents
        .where(notify: true)
  end

  def default_localization
    self.time_zone = Tenant.current_tenant.default_time_zone if time_zone.blank?
    self.locale = Tenant.current_tenant.default_locale if locale.blank?
  end
end
