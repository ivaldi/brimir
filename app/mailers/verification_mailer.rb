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

class VerificationMailer < ActionMailer::Base

  def verify(email_address)
    headers['X-Brimir-Verification'] = email_address.verification_token
    mail(to: email_address)
  end

  def receive(email)
    to_verify = EmailAddress.where.not(verification_token: nil)

    if to_verify.count > 0
      to_verify.each do |email_address|
        if email['X-Brimir-Verification'].to_s == email_address.verification_token
          email_address.verification_token = nil
          email_address.save!

          return true
        end
      end
    end

    return false
  end
end
