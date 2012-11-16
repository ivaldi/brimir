class TicketMailer < ActionMailer::Base
  default from: "from@example.com"

  def receive(email)
    content = ''
    if email.multipart?
      if email.html_part
        content = email.text_part.body.decoded
      else 
        content = email.html_part.body.decoded 
      end
    else
      content = email.body.decoded
    end

    ticket = Ticket.create({
      from: email.from.join(', '),
      subject: email.subject,
      content: content,
      status_id: Status.where(name: 'New')
    })

    if email.has_attachments?

      email.attachments.each do |attachment|

        ticket.attachments.create()

      end

    end

  end

end
