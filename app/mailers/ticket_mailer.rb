class TicketMailer < ActionMailer::Base
  default from: "from@example.com"

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
    else
      reply_to = replies_without_current.last
    end

    headers['In-Reply-To'] = '<' + reply_to.message_id + '>'

    mail = mail(to: 'frank@ivaldi.nl', subject: '')
  end

  def receive(email)
    content = ''

    if email.multipart?
      if email.html_part
        content = email.html_part.body.decoded
      else 
        content = email.text_part.body.decoded 
      end
    else
      content = email.body.decoded
    end


    # is this a reply to a ticket or to another reply?
    response_to = Ticket.find_by_message_id(email.in_reply_to)

    if !response_to
      response_to = Reply.find_by_message_id(email.in_reply_to)
    end

    from_user = User.find_by_email(email.from.first)

    if !from_user
      password_length = 12
      password = Devise.friendly_token.first(password_length)
      from_user = User.create(email: email.from.first, password: password, password_confirmation: password)
    end

    if response_to

      incoming = Reply.create({
        content: content,
        ticket_id: response_to.id,
        user_id: from_user.id
      })

    else

      incoming = Ticket.create({
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

  end

end
