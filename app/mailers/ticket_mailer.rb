# Brimir is a helpdesk system that can be used to handle email support requests.
# Copyright (C) 2012 Ivaldi http://ivaldi.nl
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

  def reply(reply)
    @reply = reply

    replies_without_current = reply.ticket.replies.select do |r|
      r != reply
    end

    references = replies_without_current.collect do |r|
      '<' + r.message_id + '>'
    end

    headers['References'] = references.join(' ')

    if replies_without_current.size == 0
      reply_to = reply.ticket
      subject = reply_to.subject
    else
      reply_to = replies_without_current.last
      subject = replies_without_current.first.ticket.subject
    end

    headers['In-Reply-To'] = '<' + reply_to.message_id + '>'

    mail = mail(to: reply_to.user.email, subject: 'Re: ' + subject)
  end

  def receive(email)
    content = ''

    if email.multipart?
      if email.html_part
        content = email.html_part.body.decoded.force_encoding(email.html_part.charset).encode('UTF-8')
      else 
        content = '<pre>' + email.text_part.body.decoded.force_encoding(email.text_part.charset).encode('UTF-8') + '</pre>'
      end
    else
      if email.charset
        content = '<pre>' + email.body.decoded.force_encoding(email.charset).encode('UTF-8') + '</pre>'
      else
        content = '<pre>' + email.body.decoded.encode('UTF-8') + '</pre>'
      end
    end


    if email.in_reply_to
      # is this a reply to a ticket or to another reply?
      response_to = Ticket.find_by_message_id(email.in_reply_to)

      if !response_to
        response_to = Reply.find_by_message_id(email.in_reply_to)
      end
    end

    from_user = User.find_by_email(email.from.first)

    if !from_user
      password_length = 12
      password = Devise.friendly_token.first(password_length)
      from_user = User.create!(email: email.from.first, password: password, password_confirmation: password)
    end

    if response_to

      incoming = Reply.create!({
        content: content,
        ticket_id: response_to.id,
        user_id: from_user.id
      })

    else

      incoming = Ticket.create!({
        user_id: from_user.id,
        subject: email.subject,
        content: content,
        status_id: Status.where(name: 'Open').first.id,
        message_id: email.message_id
      })

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

    return incoming

  end

end
