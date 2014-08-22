class Api::V1::SessionsController < ActionController::Base

  def create
    if params[:email].present? && params[:password].present?

      # find user
      user = User.find_by(email: params[:email])
      if user.present? && user.valid_password?(params[:password])
        auth_token = SecureRandom.urlsafe_base64(10).tr('lIO0', 'sxyz')

        user.authentication_token = auth_token
        user.save!

        return render json: { authorization_token: auth_token }.to_json
      end

    end

    return render json: { error: 'Wrong credentials' }.to_json

  end

end
