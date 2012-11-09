class TicketMailer < ActionMailer::Base
  default from: "from@example.com"

  def receive(email)
    Ticket.create({
      from: email.from.join(', '),
      subject: email.subject,
      content: email.body
    })
  end

end
