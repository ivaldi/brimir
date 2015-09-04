# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2015 Ivaldi https://ivaldi.nl/
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
