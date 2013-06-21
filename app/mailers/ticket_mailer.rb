# Brimir is a helpdesk system to handle email support requests.
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

    replies_without_current = reply.ticket.replies.order(:id).select do |r|
      r != reply
    end

    references = replies_without_current.collect do |r|
      '<' + r.message_id.to_s + '>'
    end

    headers['References'] = references.join(' ')

    if replies_without_current.size == 0
      reply_to = reply.ticket
      subject = reply_to.subject
    else
      reply_to = replies_without_current.last
      subject = replies_without_current.first.ticket.subject
    end

    headers['In-Reply-To'] = '<' + reply_to.message_id.to_s + '>'

    @reply.attachments.each do |at|
      attachments[at.file_file_name] = File.read(at.file.path)
    end

    mail(to: reply.ticket.user.email, subject: 'Re: ' + subject)
  end

  def notify_assignee(ticket)
    @ticket = ticket

    mail(to: ticket.assignee.email, subject:
        'Ticket assigned to you: ' + ticket.subject)
  end

  def notify_agents(ticket)

    agents = []

    agents << ticket.assignee.email unless ticket.assignee.nil?

    ticket.replies.each do |reply|
      if reply.user.agent
        agents.append(reply.user.email)
      end
    end

    if agents.size == 0
      # notify all agents
      agents = User.agents.pluck(:email)
    else
      # only the ones concerned, without duplicates
      agents = agents.uniq
    end

    @ticket = ticket

    mail(to: agents, subject: 'New reply to: ' + ticket.subject,
        template_name: 'notify_agents') # without template_name
                                        # the functional tests fail
  end

  def normalize_body(part, charset) 
    part.body.decoded.force_encoding(charset).encode('UTF-8')
  end

  def receive(message)
    require 'mail'

    email = Mail.new(message)

    content = ''

    if email.multipart?
      if email.html_part
        content = normalize_body(email.html_part, email.html_part.charset)
      else 
        content = '<pre>' + normalize_body(email.text_part, email.text_part.charset) + '</pre>'
      end
    else
      if email.charset
        content = '<pre>' + normalize_body(email, email.charset) + '</pre>'
      else
        content = '<pre>' + email.body.decoded.encode('UTF-8') + '</pre>'
      end
    end


    if email.in_reply_to
      # is this a reply to a ticket or to another reply?
      response_to = Ticket.find_by_message_id(email.in_reply_to)

      if !response_to

        response_to = Reply.find_by_message_id(email.in_reply_to)
        ticket = response_to.ticket

      else
        ticket = response_to
      end
    end

    from_user = User.find_by_email(email.from.first)

    if !from_user
      password_length = 12
      password = Devise.friendly_token.first(password_length)
      from_user = User.create!(email: email.from.first, password: password, password_confirmation: password)
    end

    if response_to
      ticket.status = Status.where(name: 'Open').first
      ticket.save

      incoming = Reply.create!({
        content: content,
        ticket_id: ticket.id,
        user_id: from_user.id,
        message_id: email.message_id
      })

    else

      incoming = Ticket.create!({
        user_id: from_user.id,
        subject: email.subject,
        content: content,
        status_id: Status.where(name: 'Open').first.id,
        message_id: email.message_id
      })

      ticket = incoming

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

    notify_agents(ticket).deliver

    return incoming

  end

end
