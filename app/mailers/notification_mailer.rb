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

class NotificationMailer < ActionMailer::Base

  def new_ticket(created_by, ticket)

    #customer created ticket for another user
    if !created_by.agent? && created_by != ticket.user
      to = agents_to_notify + [ticket.user.email]
    #ticket created by customer
    elsif !created_by.agent?
      to = agents_to_notify
    #ticket created by agent for another user
    elsif created_by.agent? && created_by != ticket.user
      to = [ticket.user.email]
    #agent created ticket for himself (or herself ;))
    else
      return
    end

    title = I18n::translate(:new_ticket) + ': ' + ticket.subject

    add_attachments(ticket)

    @ticket = ticket

    mail(to: to, subject: title)
  end

  def new_reply(created_by, reply)

    to = thread_users_to_notify(reply)

    title = I18n::translate(:new_reply) + ': ' + reply.ticket.subject

    add_attachments(reply)
    add_reference_message_ids(reply)
    add_in_reply_to_message_id(reply)

    @reply = reply

    mail(to: to, subject: title)

  end

  protected
    def agents_to_notify
      User.agents
          .where(notify: true)
          .pluck(:email)
    end

    def thread_users_to_notify(reply)
      to = [reply.ticket.user.email]

      reply.other_replies.each do |r|
        to << r.user.email
      end

      assignee = reply.ticket.assignee
      if assignee.present?
        to += [assignee.email]
      end

      to.uniq
    end

    def add_reference_message_ids(reply)
      references = reply.other_replies.with_message_id.pluck(:message_id)

      if references.count > 0
        headers['References'] = '<' + references.join('> <') + '>'
      end
    end

    def add_in_reply_to_message_id(reply)

      last_reply = reply.other_replies.order(:id).last

      if last_reply.nil?
        headers['In-Reply-To'] = '<' + reply.ticket.message_id.to_s + '>'
      else
        headers['In-Reply-To'] = '<' + last_reply.message_id.to_s + '>'
      end

    end

    def add_attachments(ticket_or_reply)
      ticket_or_reply.attachments.each do |at|
        attachments[at.file_file_name] = File.read(at.file.path)
      end
    end

end