require 'test_helper'

class LabelingTest < ActiveSupport::TestCase

  test 'should create label for new name' do

    assert_difference 'Label.count' do
      labeling = Labeling.new(
          label: {
              name: 'New label'
          },
          labelable: Ticket.first
      )

      assert_not_nil labeling.label
      assert_equal 'New label', labeling.label.name
    end

  end

  test 'should not create label for existing name' do

    assert_no_difference 'Label.count' do
      labeling = Labeling.new(
          label: {
              name: labels(:bug).name
          },
          labelable: Ticket.first
      )

      assert_not_nil labeling.label
      assert_equal labels(:bug).name, labeling.label.name
    end

  end

end
