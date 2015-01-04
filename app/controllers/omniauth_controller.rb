class OmniauthController < ApplicationController

  def callback
    @user = User.find_or_create_from_auth_hash(auth_hash)
    self.current_user = @user
    redirect_to '/'
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
