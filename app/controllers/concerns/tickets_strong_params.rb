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

module TicketsStrongParams
  extend ActiveSupport::Concern
  protected
  def ticket_params
    if !current_user.nil? && current_user.agent?
      params.require(:ticket).permit(
        :from,
        :to_email_address_id,
        :content,
        :subject,
        :status,
        :assignee_id,
        :priority,
        :message_id,
        :content_type,
        attachments_attributes: [
          :file
        ])
    else
      params.require(:ticket).permit(
        :from,
        :content,
        :subject,
        :priority,
        :content_type,
        attachments_attributes: [
          :file
        ])
    end
  end

end
