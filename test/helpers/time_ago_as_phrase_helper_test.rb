require 'test_helper'

class TimeAgoAsPhraseHelperTest < ActionView::TestCase
  include TimeHelper

  setup do
    @time = Time.now - 5.minutes
  end

  test 'should postfix "ago" in English' do
    I18n.locale = :en
    assert_equal time_ago_as_phrase(@time), "5 minutes ago"
  end

  test 'should prefix "il y a" in French' do
    I18n.locale = :'fr-FR'
    assert_equal time_ago_as_phrase(@time), "il y a 5 minutes"
  end

end
