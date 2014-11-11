require 'test_helper'

class RuleTest < ActiveSupport::TestCase
  test 'should set priority correctly' do
    Rule.create filter_field: 'from',
        filter_value: '@',
        filter_operation: 'contains',
        action_operation: 'change_priority',
        action_value: 'high'

    ticket = Ticket.create from: 'test@test.nl',
        content: 'problem'

    assert_equal 'unknown', ticket.priority

    Rule.apply_all(ticket)

    assert_equal 'high', ticket.priority

  end
end
