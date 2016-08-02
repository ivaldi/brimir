require 'test_helper'

class TicketMergeTest < ActiveSupport::TestCase

  test 'merging two tickets' do
    client_user = User.where(agent: false).first
    agent_user = User.where(agent: true).first
    first_ticket = Ticket.create subject: "First ticket", content: "I've got a question ...", user_id: client_user.id
    Timecop.travel 2.minutes.from_now
    first_reply = first_ticket.replies.create content: "Please send me some more info about ...", user_id: agent_user.id
    Timecop.travel 20.minutes.from_now
    second_ticket = Ticket.create subject: "Second ticket", content: "I forgot to mention ...", user_id: client_user.id
    Timecop.travel 1.hour.from_now

    second_ticket_updated_at_before_merge = second_ticket.updated_at

    separate_tickets = [first_ticket, second_ticket]
    merged_ticket = MergedTicket.from separate_tickets

    assert_equal 2, merged_ticket.replies.count
    assert_equal merged_ticket.id, first_ticket.id
    assert merged_ticket.replies.pluck(:content).include? "Please send me some more info about ..."
    assert merged_ticket.replies.pluck(:content).include? "I forgot to mention ..."
    assert merged_ticket.replies.order(:created_at).first.user == agent_user
    assert merged_ticket.replies.order(:created_at).last.user == client_user
    assert_equal merged_ticket.replies.order(:created_at).last.created_at.to_i, second_ticket.created_at.to_i
    assert_equal merged_ticket.replies.order(:created_at).last.updated_at.to_i, second_ticket_updated_at_before_merge.to_i
  end

  test 'merging two tickets and providing an agent who is performing the merge' do
    client_user = User.where(agent: false).first
    agent_user = User.where(agent: true).first
    first_ticket = Ticket.create subject: "First ticket", content: "I've got a question ...", user_id: client_user.id
    Timecop.travel 2.minutes.from_now
    second_ticket = Ticket.create subject: "Second ticket", content: "I forgot to mention ...", user_id: client_user.id

    merged_ticket = MergedTicket.from [first_ticket, second_ticket], current_user: agent_user
    second_ticket.reload

    assert_equal 1, merged_ticket.replies.count
    assert second_ticket.replies.last.user == agent_user
    assert second_ticket.replies.last.internal == true
    assert second_ticket.replies.last.content.include? first_ticket.id.to_s
    assert second_ticket.status == 'merged'
  end

  test 'merging two tickets and copying over the notifications' do
    client_user = User.where(agent: false).first
    agent_user = User.where(agent: true).first
    first_ticket = Ticket.create subject: "First ticket", content: "I've got a question ...", user_id: client_user.id
    first_ticket.notified_users << agent_user
    Timecop.travel 2.minutes.from_now
    second_ticket = Ticket.create subject: "Second ticket", content: "I forgot to mention ...", user_id: client_user.id
    second_ticket.notified_users << agent_user
    Timecop.travel 4.minutes.from_now
    second_reply = second_ticket.replies.create content: "Please send me some more info about ...", user_id: agent_user.id
    second_reply.notified_users << client_user

    merged_ticket = MergedTicket.from [first_ticket, second_ticket], current_user: agent_user

    assert merged_ticket.notified_users.include? agent_user
    assert merged_ticket.replies.order(:created_at).first.notified_users.include? agent_user
    assert merged_ticket.replies.order(:created_at).last.notified_users.include? client_user
  end

  test 'merging tickets with attachments' do
    client_user = User.where(agent: false).first
    agent_user = User.where(agent: true).first
    first_ticket = Ticket.create subject: "First ticket", content: "I've got a question ...", user_id: client_user.id
    Timecop.travel 2.minutes.from_now
    first_reply = first_ticket.replies.create content: "Please send me some more info about ...", user_id: agent_user.id
    Timecop.travel 20.minutes.from_now
    second_ticket = Ticket.create subject: "Second ticket", content: "I forgot to mention ...", user_id: client_user.id
    Timecop.travel 1.hour.from_now

    first_attachment = first_ticket.attachments.create!
    second_attachment = second_ticket.attachments.create!

    reply_with_attachment = second_ticket.replies.create! content: "Reply with attachment"
    reply_attachment = reply_with_attachment.attachments.create!

    separate_tickets = [first_ticket, second_ticket]
    merged_ticket = MergedTicket.from separate_tickets

    assert merged_ticket.attachments.include? first_attachment
    assert merged_ticket.replies.collect { |reply| reply.attachments }.flatten.include? reply_attachment
    assert_equal merged_ticket.replies.collect { |reply| reply.attachments }.flatten.count, [second_attachment, reply_attachment].count
  end

  test 'accessing attachment file for merged ticket' do
    # Create two tickets with one attachment each.
    ticket1 = tickets(:problem)
    ticket2 = tickets(:daves_problem)
    ticket1.attachments.create! file: File.open('test/fixtures/attachments/default-testpage.pdf')
    ticket2.attachments.create! file: File.open('test/fixtures/attachments/default-testpage.pdf')
    assert File.file? ticket1.attachments.first.file.path(:original)
    assert File.file? ticket2.attachments.first.file.path(:original)

    # Merge tickets and make sure the message ids are as expected.
    merged_ticket = MergedTicket.from [ticket1, ticket2]
    assert_equal merged_ticket.message_id, ticket1.message_id
    assert_equal merged_ticket.replies.last.message_id, ticket2.message_id

    # Test if the attachment files can still be accessed.
    assert File.file? merged_ticket.attachments.first.file.path(:original)
    assert File.file? merged_ticket.replies.last.attachments.first.file.path(:original)

    # Actually, it should point to the same physical file.
    assert_equal ticket1.attachments.first.file.path(:original), merged_ticket.attachments.first.file.path(:original)
    assert_equal ticket2.attachments.first.file.path(:original), merged_ticket.replies.last.attachments.first.file.path(:original)
  end

  test 'accessing attachment file for merged reply' do
    # Create two tickets and attach a file to a reply.
    ticket1 = tickets(:daves_problem); ticket1.update! created_at: 1.hour.ago
    ticket2 = tickets(:problem); ticket2.update! created_at: 30.minutes.ago
    ticket2.replies.first.update! created_at: 15.minutes.ago
    ticket2.replies.first.attachments.create! file: File.open('test/fixtures/attachments/default-testpage.pdf')
    assert File.file? ticket2.replies.first.attachments.first.file.path(:original)

    # Merge tickets and make sure the message ids are as expected.
    merged_ticket = MergedTicket.from [ticket1, ticket2]
    assert_equal merged_ticket.message_id, ticket1.message_id
    assert_equal merged_ticket.replies.count, 2
    assert_equal merged_ticket.replies.order(:created_at).first.message_id, ticket2.message_id
    assert_equal merged_ticket.replies.order(:created_at).last.message_id, ticket2.replies.first.message_id

    # Test if the attachment file can still be accessed.
    assert File.file? merged_ticket.replies.order(:created_at).last.attachments.first.file.path(:original)
  end

  test 'accessing raw message for merged ticket' do
    # Create two tickets with a raw message fake each.
    ticket1 = tickets(:problem)
    ticket2 = tickets(:daves_problem)
    ticket1.update! raw_message: File.open('test/fixtures/attachments/default-testpage.pdf')
    ticket2.update! raw_message: File.open('test/fixtures/attachments/default-testpage.pdf')
    assert File.file? ticket1.raw_message.path(:original)
    assert File.file? ticket2.raw_message.path(:original)

    # Merge tickets and check if the raw message can still be accessed.
    merged_ticket = MergedTicket.from [ticket1, ticket2]
    assert File.file? merged_ticket.raw_message.path(:original)
    assert File.file? merged_ticket.replies.last.raw_message.path(:original)
  end

  test 'accessing raw message for merged reply' do
    # Create two tickets and attach a raw message fake to a reply.
    ticket1 = tickets(:daves_problem); ticket1.update! created_at: 1.hour.ago
    ticket2 = tickets(:problem); ticket2.update! created_at: 30.minutes.ago
    ticket2.replies.first.update! created_at: 15.minutes.ago
    ticket2.replies.first.update! raw_message: File.open('test/fixtures/attachments/default-testpage.pdf')
    assert File.file? ticket2.replies.first.raw_message.path(:original)

    # Merge tickets and check if the raw message can still be accessed.
    merged_ticket = MergedTicket.from [ticket1, ticket2]
    assert File.file? merged_ticket.replies.order(:created_at).last.raw_message.path(:original)
  end

end
