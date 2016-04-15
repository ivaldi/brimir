# Brimir is a helpdesk system to handle email support requests.
# Copyright (C) 2012-2016 Ivaldi https://ivaldi.nl/
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

class EmailAddressesController < ApplicationController

  load_and_authorize_resource :email_address

  def index
    @email_addresses = @email_addresses.ordered.page(params[:page])
  end

  def new
  end

  def create
    @email_address.assign_attributes(email_address_params)

    if @email_address.save
      VerificationMailer.verify(@email_address)
          .deliver_now

      redirect_to email_addresses_url, notice: I18n.t(:email_address_added)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    # allow changing everything except email field
    attributes = email_address_params
    attributes.delete(:email)

    @email_address.assign_attributes(attributes)

    if @email_address.save
      redirect_to email_addresses_url, notice: I18n.t(:email_address_modified)
    else
      render 'edit'
    end
  end

  def destroy
    @email_address.destroy
    redirect_to email_addresses_url, notice: I18n.t(:email_address_removed)
  end

  protected

  def email_address_params
    params.require(:email_address).permit(
      :name,
      :email,
      :default
    )
  end

end
