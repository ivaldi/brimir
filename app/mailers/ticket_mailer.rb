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

class TicketMailer < ActionMailer::Base

  def notify_status_changed(ticket)
    @ticket = ticket

    mail(to: ticket.assignee.email, subject:
        'Ticket status modified in ' + ticket.status + ' for: ' \
        + ticket.subject)
  end

  def notify_priority_changed(ticket)
    @ticket = ticket

    mail(to: ticket.assignee.email, subject:
        'Ticket priority modified in ' + ticket.priority + ' for: ' \
        + ticket.subject)
  end

  def notify_assigned(ticket)
    @ticket = ticket

    mail(to: ticket.assignee.email, subject:
        'Ticket assigned to you: ' + ticket.subject)
  end


  def normalize_body(part, charset)
    part.body.decoded.force_encoding(charset).encode('UTF-8')
  end

  def receive(message)
    require 'mail'

    email = Mail.new(message)

    content = ''

    if email.multipart?
      if email.text_part
        content = normalize_body(email.text_part, email.text_part.charset)
        content_type = 'text'
      else
        content = normalize_body(email.html_part, email.html_part.charset)
        content_type = 'html'
      end
    else
      if email.charset
        content = normalize_body(email, email.charset)
      else
        content = email.body.decoded.encode('UTF-8')
      end
      content_type = 'text'
    end


    if email.in_reply_to
      # is this a reply to a ticket or to another reply?
      response_to = Ticket.find_by_message_id(email.in_reply_to)

      if !response_to

        response_to = Reply.find_by_message_id(email.in_reply_to)

        if response_to
          ticket = response_to.ticket
        else
          # we create a new ticket further below in this case
        end
      else
        ticket = response_to
      end
    end

    if response_to
      # reopen ticket
      ticket.status = :open
      ticket.save

      # add reply
      incoming = Reply.create!({
        content: content,
        ticket_id: ticket.id,
        from: email.from.first,
        message_id: email.message_id,
        content_type: content_type
      })

    else

      # add new ticket
      ticket = Ticket.create!({
        from: email.from.first,
        subject: email.subject,
        content: content,
        message_id: email.message_id,
        content_type: content_type,
      })

      incoming = ticket

    end

    if email.has_attachments?

      email.attachments.each do |attachment|

        file = StringIO.new(attachment.decoded)

        # add needed fields for paperclip
        file.class.class_eval {
            attr_accessor :original_filename, :content_type
        }

        file.original_filename = attachment.filename
        file.content_type = attachment.mime_type 

        a = incoming.attachments.create(file: file)
        a.save! # FIXME do we need this because of paperclip?
      end

    end

    if ticket != incoming
      incoming.set_default_notifications!

      incoming.notified_users.each do |user|
        mail = NotificationMailer.new_reply(incoming, user)
        mail.deliver
        incoming.message_id = mail.message_id
      end

      incoming.save
    end

    return incoming

  end
end
