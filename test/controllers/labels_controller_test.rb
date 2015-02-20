require 'test_helper'

class LabelsControllerTest < ActionController::TestCase

  setup do
    sign_in users(:alice)
  end
  
  test 'should get select2 json' do
    get :index, format: :json
    assert_response :success

    result = ActiveSupport::JSON.decode @response.body

    assert_equal 2, result.size
    assert_not_nil result[0]['id']
    assert_not_nil result[0]['text']
  end
end
