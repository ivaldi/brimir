# Brimir is a helpdesk system that can be used to handle email support requests.
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

class EmailAddress < ActiveRecord::Base

  validates_uniqueness_of :email

  before_save :ensure_one_default
  before_create :generate_verification_token

  scope :ordered, -> {
    order(:email)
  }

  def self.default_email

    if !EmailAddress.where(default: true, verification_token: nil).first.nil?
      return EmailAddress.where(default: true, verification_token: nil).first.email

    elsif ActionMailer::Base.default[:from].present?
      ActionMailer::Base.default[:from]

    elsif Rails.configuration.action_mailer.default_options.present?
      Rails.configuration.action_mailer.default_options[:from]

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
