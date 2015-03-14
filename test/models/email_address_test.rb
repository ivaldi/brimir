require 'test_helper'

class EmailAddressTest < ActiveSupport::TestCase

  test 'should use correct default address' do
    assert_equal 'outgoing@support.bla', EmailAddress.default_email

    EmailAddress.delete_all

    Rails.configuration.action_mailer.default_options[:from] = 'brimir@test.host'
    assert_equal 'brimir@test.host', EmailAddress.default_email

    Rails.configuration.action_mailer.default_options.delete :from
    ActionMailer::Base.default from: 'brimir@xxxx.com'
    assert_equal 'brimir@xxxx.com', EmailAddress.default_email

  end

end
