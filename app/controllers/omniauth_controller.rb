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
        # TODO: a redirect to :back could be nice
        redirect_to root_url, notice: I18n.translate(:already_linked_accounts)
      else
        # The identity is not associated with the current_user so lets
        # associate the identity
        @identity.user = current_user
        @identity.save
        # TODO: a redirect to :back could be nice
        redirect_to root_url, notice: I18n.translate(:successfully_linked_account)
      end
    else
      if @identity.user.present?
        # The identity we found had a user associated with it so let's
        # just log them in here
        sign_in @identity.user
        redirect_to root_url, notice: I18n.translate(:signed_in_with_omniauth)
      else
        # No user associated with the identity so we reject this attemp
        # TODO: concept and texts
        redirect_to new_user_session_path, alert: I18n.translate(:not_linked_account_cant_login)

      end
    end
  end

  def failure
    redirect_to root_url,  alert: I18n.translate(:third_party_failure)
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
