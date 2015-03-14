class AddContentTypesToRepliesAndTickets < ActiveRecord::Migration
  def change
    Reply.all.each do |reply|
      if reply.content_type == 'markdown'
        reply.content_type = 'html'
        reply.save
      end
    end

    Ticket.all.each do |ticket|
      if ticket.content_type == 'markdown'
        ticket.content_type = 'html'
        ticket.save
      end
    end
  end
end
