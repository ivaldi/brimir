require 'test_helper'

class RuleTest < ActiveSupport::TestCase

  setup do
    @filters = [:from, :subject, :content, :orig_to, :orig_cc]
    @rule = Rule.create({
      filter_field: 'from',
      filter_value: '@',
      filter_operation: 'contains',
      action_operation: 'change_priority', # field can't be empty so default to this
      action_value: 'unknown' # field can't be empty so default to this
    })
    @ticket = Ticket.create({
      from: 'test@test.nl',
      orig_cc: 'dummy2@example.com, dummy3@example.com',
      orig_to: 'support@ivaldi.nl',
      content: 'problem'
    })
  end

  test 'should set priority correctly' do
    priorities = Ticket.priorities.keys
    # we test this action
    @rule.update_attribute(:action_operation, 'change_priority')

    priorities.each do |priority|
      # default the ticket priority for each iteration
      @ticket.update_attribute(:priority, 'unknown')

      # use same rule only test for different action_value
      @rule.update_attribute(:action_value, priority)

      # check if the ticket priority is reset to default
      assert_equal 'unknown', @ticket.priority

      @filters.each do |filter|
        @rule.update_attribute(:filter_field, filter)
        Rule.apply_all @ticket
      end

      # priority should be changed
      assert_equal priority, @ticket.priority
    end
  end

  test 'should set labels' do
    labels = ["bug", "change-request", "feature-request", "feedback"]
    # we test this action
    @rule.update_attribute(:action_operation, 'assign_label')

    labels.each do |label|
      #empty the labels collection for each iteration
      @ticket.update_attribute(:labels, [])

      # use same rule only test for different action_value
      @rule.update_attribute(:action_value, label)

      # check if the ticket labels are reset to default
      assert @ticket.labels.empty?

      @filters.each do |filter|
        @rule.update_attribute(:filter_field, filter)

        Rule.apply_all @ticket

        assert_includes @ticket.labels.collect{|l| l.name.downcase}, label
      end
    end
  end

  test 'should assign user' do
    dummy = User.create({
      email: 'dummy@example.com',
      agent: true,
      name: "dummy",
      signature: 'Greets, Dummy',
      authentication_token: 'blabla',
      notify: true
    })
    # we test this action
    @rule.update_attribute(:action_operation, 'assign_user')

    # use same rule only test for different action_value
    @rule.update_attribute(:action_value, dummy.email)

    # check default ticket assignee
    assert_nil @ticket.assignee

    @filters.each do |filter|
      @rule.update_attribute(:filter_field, filter)
      Rule.apply_all @ticket

      assert_equal @ticket.assignee, dummy
    end
  end

  test 'should add statuses' do
    statuses = Ticket.statuses.keys
    # we test this action
    @rule.update_attribute(:action_operation, 'change_status')

    statuses.each do |status|
      # default the ticket status for each iteration
      @ticket.update_attribute(:status, statuses[0])

      # use same rule only test for different action_value
      @rule.update_attribute(:action_value, status)

      # check if ticket status is reset to default
      assert_equal statuses[0], @ticket.status

      @filters.each do |filter|
        @rule.update_attribute(:filter_field, filter)
        Rule.apply_all @ticket

        assert_equal status, @ticket.status
      end
    end
  end

  test 'should set notify user' do
    dummy = User.create({
      email: 'dummy@example.com',
      agent: true,
      name: "dummy",
      signature: 'Greets, Dummy',
      authentication_token: 'blabla',
      notify: true
    })
    # we test this action
    @rule.update_attribute(:action_operation, 'notify_user')
    # use same rule only test for different action_value
    @rule.update_attribute(:action_value, dummy.email)

    # check the ticket notified_users collection
    assert @ticket.notified_users.empty?

    @filters.each do |filter|
      @rule.update_attribute(:filter_field, filter)
      Rule.apply_all @ticket

      assert_includes @ticket.notified_users, dummy
    end
  end

end
