class TicketMailer < ActionMailer::Base
  default from: "from@example.com"

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

    ticket = Ticket.create({
      from: email.from.join(', '),
      subject: email.subject,
      content: content,
      status_id: Status.where(name: 'Open')
    })

    if email.has_attachments?

      email.attachments.each do |attachment|

        file = StringIO.new(attachment.decoded)

        # add needed fields for paperclip
        file.class.class_eval {
            attr_accessor :original_filename, :content_type
        }

        file.original_filename = attachment.filename
        file.content_type = attachment.mime_type 

        a = ticket.attachments.create(file: file)
        a.save! # FIXME do we need this because of paperclip?
      end

    end

  end

end
