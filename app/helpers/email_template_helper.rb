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

# helpers used for EmailTemplate views
module EmailTemplateHelper
  def check_settings(tenant, email_template)
    # prompt confirmation
    if email_template.is_active?
      response = case email_template.kind
      when 'user_welcome'
        prefix = t(:deleting_this_item_will_unset_option)
        postfix = t(
            'activerecord.attributes.tenant.notify_user_when_account_is_created')
        prefix + ' ' + postfix
      when 'ticket_received'
        prefix = t(:deleting_this_item_will_unset_option)
        postfix = t(
            'activerecord.attributes.tenant.notify_client_when_ticket_is_created')
        prefix + ' ' + postfix
      end
      return response # return the response
    end
    t(:are_you_sure) # regular confirmation
  end

  # prompt user if active is already set
  def ask_if_not_draft_exists(collection, kind)
    return if collection.empty?
    active = collection.exists?(
        ['kind = ? and draft = ?', EmailTemplate.kinds[kind], false])
    if active
      t(:already_active_template, kind: kind.humanize)
    end
  end
end
