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

class Rule < ActiveRecord::Base

  validates_presence_of :filter_field, :filter_value

  enum filter_operation: [:contains]
  enum action_operation: [:assign_label, :notify_user, :change_status]

  def filter(ticket)

    if ticket.respond_to?(filter_field)
      value = ticket.send(filter_field)
    else
      value = ticket.attributes[filter_field]
    end

    if filter_operation == 'contains'
      value.include?(filter_value)
    end
  end

  def execute(ticket)
    if action_operation == 'assign_label'
      label = Label.where(name: action_value).first_or_create
      ticket.labels << label

    elsif action_operation == 'notify_user'
      user = User.where(email: action_value).first

      unless user.nil?
        ticket.notified_users << user
      end

    elsif action_operation == 'change_status'
      ticket.status = action_value
      ticket.save

    end
  end

  def self.apply_all(ticket)

    Rule.all.each do |rule|
      if rule.filter(ticket)
        rule.execute(ticket)
      end
    end
  end

end
