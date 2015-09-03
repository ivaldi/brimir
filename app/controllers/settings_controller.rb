class SettingsController < ApplicationController

  def edit
    @tenant = Tenant.current_tenant
    authorize! :edit, @tenant
  end

  def update
    @tenant = Tenant.current_tenant
    authorize! :update, @tenant

    if @tenant.update_attributes(tenant_params)
      redirect_to tickets_url, notice: I18n.t(:settings_saved)
    else
      render 'edit'
    end
  end

  protected

  def tenant_params
    params.require(:tenant).permit(
      :default_time_zone,
      :ignore_user_agent_locale,
      :default_locale
    )
  end
end
