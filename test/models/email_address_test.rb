require 'test_helper'

class EmailAddressTest < ActiveSupport::TestCase

  test 'should use correct default address' do
    Tenant.current_domain = Tenant.first.domain

    assert_equal 'outgoing@support.bla', EmailAddress.default_email

    EmailAddress.delete_all

    assert_equal 'support@test.host', EmailAddress.default_email
  end

end
