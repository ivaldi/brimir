require 'test_helper'

class Api::V1::UsersControllerTest < ActionController::TestCase

  setup do
    @ticket = tickets(:problem)
    @alice = users(:alice)
    @bob = users(:bob)
    @charlie = users(:charlie)
  end

  test 'should find a User' do
    get :show, auth_token: users(:alice).authentication_token, email: Base64.urlsafe_encode64(users(:alice).email), :format => :json
    assert_response :success
  end

  test 'should create a User ' do
    sign_in users(:alice)
    assert_difference 'User.count', 1 do
      post :create, auth_token: users(:alice).authentication_token, user: {
        email: 'newuser@new.com'}, 
        format: :json
    end
    assert_response :success
  end

end