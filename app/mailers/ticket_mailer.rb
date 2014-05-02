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

    reply.attachments.each do |at|
      attachments[at.file_file_name] = File.read(at.file.path)
    end

    mail(to: reply.to, cc: reply.cc, bcc: reply.bcc, subject: 'Re: ' \
        + subject)
  end

  def notify_status_changed(ticket)
    @ticket = ticket

    mail(to: ticket.assignee.email, subject:
        'Ticket status modified in ' + ticket.status + ' for: ' \
        + ticket.subject)
  end

  def notify_priority_changed(ticket)
    @ticket = ticket

    mail(to: ticket.assignee.email, subject:
        'Ticket priority modified in ' + ticket.priority.name + ' for: ' \
        + ticket.subject)
  end

  def notify_assigned(ticket)
    @ticket = ticket

    mail(to: ticket.assignee.email, subject:
        'Ticket assigned to you: ' + ticket.subject)
  end

  def notify_agents(ticket, incoming)

    agents = []

    agents << ticket.assignee.email unless ticket.assignee.nil?

    ticket.replies.each do |reply|
      if reply.user.agent
        agents.append(reply.user.email)
      end
    end

    if agents.size == 0
      # notify all agents
      agents = User.agents.where(notify: true).pluck(:email)
    else
      # only the ones concerned, without duplicates
      agents = agents.uniq
    end

    @ticket = ticket
    @incoming = incoming

    title = 'New reply to: ' + ticket.subject
    if incoming == ticket
      title = 'New ticket: ' + ticket.subject
    end

    mail(to: agents, subject: title,
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

    # search using the same method as Devise validation
    from_user = User.find_first_by_auth_conditions(email: email.from.first)

    if !from_user
      password_length = 12
      password = Devise.friendly_token.first(password_length)
      from_user = User.create!(email: email.from.first, password: password,
          password_confirmation: password)
    end

    if response_to
      # reopen ticket
      ticket.status = :open
      ticket.content_type = content_type
      ticket.save

      # add reply
      incoming = Reply.create!({
        content: content,
        ticket_id: ticket.id,
        user_id: from_user.id,
        message_id: email.message_id
      })

    else

      # add reply
      incoming = Ticket.create!({
        user_id: from_user.id,
        subject: email.subject,
        content: content,
        priority_id: Priority.default.first.id,
        message_id: email.message_id,
        content_type: content_type
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

    notify_agents(ticket, incoming).deliver

    return incoming

  end
end
