class UserParameters < ActionParameter::Base
  def permit
    params.require(:user).permit(:email, :password, :password_confirmation,
                                 :remember_me, :signature)
  end
end