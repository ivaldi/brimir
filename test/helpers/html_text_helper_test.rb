require 'test_helper'

class HtmlTextHelperTest < ActionView::TestCase
  include HtmlTextHelper

  test 'should wrap correctly at max 80 chars' do
    content = wrap_and_quote('lorem ipsum dolor sit amet' * 10)
    content.split("\n").each do |line|
      assert_operator line.length, :<=, 80 - "\n".length
    end
  end

  test 'should remove older quotes correctly' do

    content = '
hi, thanks for you reply

On date, person wrote:
> older quote
>> older quote
> > older quote
'

    stripped = wrap_and_quote(content)

    refute_match(/On date, person wrote/, stripped)
    refute_match(/older quote/, stripped)
  end
end
