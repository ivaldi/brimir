class EmailTemplatesController < ApplicationController
  include HtmlTextHelper

  load_and_authorize_resource :email_template

  def index
    @email_templates = @email_templates.page params[:page]
    @tenant = Tenant.current_tenant
  end

  def new
  end

  def create
    @email_template.assign_attributes(email_template_params)

    if @email_template.save
      redirect_to email_templates_url, notice: I18n.t(:email_template_added)
    else
      render :new
    end
  end

  def edit
    # safely output the html
    @email_template.message = @email_template.message.html_safe
  end

  def update
    # we have a new active template request
    if email_template_params[:draft].present?
      # this is not a draft anymore
      @email_template.update_attribute(:draft, false)
      # only one active version!
      @email_template.all_others_to_draft(@email_template.kind)

      return redirect_to email_templates_url, notice: I18n.t(:email_template_modified)
    end

    if @email_template.update_attributes(email_template_params)
      redirect_to email_templates_url, notice: I18n.t(:email_template_modified)
    else
      render :edit
    end
  end

  def destroy
    if @email_template.destroy
      @tenant = Tenant.current_tenant
      unless @email_template.draft

        # unset the option
        if @tenant.notify_user_when_account_is_created && @email_template
            .user_welcome? && @email_template.is_active?

          @tenant.update_attribute(:notify_user_when_account_is_created, false)
        end

        # unset the option
        if @tenant.notify_client_when_ticket_is_created && @email_template
            .ticket_received? && @email_template.is_active?

          @tenant.update_attribute(:notify_client_when_ticket_is_created, false)
        end

      end
      redirect_to email_templates_url, notice: I18n.t(:email_template_removed)
    end
  end

  protected
  def email_template_params
    params.require(:email_template).permit(
      :name,
      :draft,
      :message,
      :kind
    )
  end
end
