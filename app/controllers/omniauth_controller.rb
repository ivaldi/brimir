class OmniauthController < ApplicationController

  skip_before_filter :verify_authenticity_token, only: :callback
  skip_before_filter :authenticate_user, only: :callback
  skip_authorization_check only: :callback

  def callback
    auth = request.env['omniauth.auth']
    # Find an identity here
    @identity = Identity.find_with_omniauth(auth)

    if @identity.nil?
      # If no identity was found, create a brand new one here
      @identity = Identity.create_with_omniauth(auth)
    end

    if signed_in?
      if @identity.user == current_user
        # User is signed in so they are trying to link an identity with their
        # account. But we found the identity and the user associated with it
        # is the current user. So the identity is already associated with
        # this user. So let's display an error message.
        # TODO: a redirect to :back would be nice

        redirect_to root_url, notice: "Already linked that account!"
      else
        # The identity is not associated with the current_user so lets
        # associate the identity
        @identity.user = current_user
        @identity.save
        # TODO: a redirect to :back would be nice
        redirect_to root_url, notice: "Successfully linked that account!"
      end
    else
      if @identity.user.present?
        # The identity we found had a user associated with it so let's
        # just log them in here
        sign_in @identity.user
        redirect_to root_url, notice: "Signed in!"
      else
        # No user associated with the identity so we need to create a new one
        # TODO: concept and texts
        redirect_to new_user_session_path, alert: "There is no user attached to this provider yet! Please login first and connect in the control panel"

      end
    end
  end

  def failure
    # TODO
    redirect('/')
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
