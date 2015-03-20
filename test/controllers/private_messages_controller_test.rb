require 'test_helper'

class PrivateMessagesControllerTest < ActionController::TestCase
  setup do

    @ticket = tickets(:problem)
    @reply = replies(:solution)

    sign_in users(:alice)
  end

  test 'create private message' do
    put :create, private_message: {ticket_id: @ticket.id, message: 'test message'}
    assert 'test message', @ticket.private_messages[0].message
  end
end
