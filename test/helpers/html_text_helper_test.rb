require 'test_helper'

class HtmlTextHelperTest < ActionView::TestCase
  include HtmlTextHelper

  test 'should wrap correctly at max 80 chars' do
    content = wrap_and_quote('lorem ipsum dolor sit amet' * 10)
    content.split("\n").each do |line|
      assert_operator line.length, :<=, 80 - "\n".length
    end
  end
end
