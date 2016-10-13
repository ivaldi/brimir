class UserMailer < ActionMailer::Base
  include HtmlTextHelper

  def new_account(user, message)
    @user = user
    @message = message
    @body = match_values_inside_guillemet_and_replace_with_variable_assignments(
        @message.body,
        name: @user.name,
        email: @user.email,
        password: @user.password,
        domain: Tenant.current_tenant.domain
    )
    mail(to: @user.email, from: EmailAddress.default_email, subject: @message.subject)
  end

end
