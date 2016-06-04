# Brimir is a helpdesk system that can be used to handle email support requests.
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

class EmailAddress < ActiveRecord::Base

  validates :email, uniqueness: true, presence: true
  has_many :tickets, dependent: :nullify

  before_save :ensure_one_default
  before_create :generate_verification_token

  scope :ordered, -> { order(:default).reverse_order.order(:email) }
  scope :verified, -> { where(verification_token: nil) }

  def self.default_email
    unless EmailAddress.verified.where(default: true).first.nil?
      return EmailAddress.verified.where(default: true).first.email
    else
      Tenant.current_tenant.from
    end
  end

  def self.find_first_verified_email(addresses)
    if addresses.nil?
      nil
    else
      verified.where(email: addresses.map(&:downcase)).first
    end
  end

  def formatted
    if name.blank?
      email
    else
      "#{name} <#{email}>"
    end
  end

  protected

  def ensure_one_default
    if self.default
      EmailAddress.where.not(id: self.id).update_all(default: false) 
    end
  end

  def generate_verification_token
    self.verification_token = Devise.friendly_token
  end
end
