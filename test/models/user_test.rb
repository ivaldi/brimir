require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'should return user locale' do
    assert_equal users(:emile).locale, :fr
  end

  test 'should fall back to default locale' do
    user = users(:emile)
    user.locale = nil
    assert_equal user.locale, :en
  end

end
