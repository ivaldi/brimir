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

class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render text: exception, status: 500
  end
  protect_from_forgery with: :null_session

  before_action :load_tenant
  before_action :authenticate_user!
  before_action :set_locale
  before_action :load_labels, if: :user_signed_in?

  check_authorization unless: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    if Rails.env == :production
      redirect_to root_url, alert: exception.message
    else
      # for tests and development, we want unauthorized status codes
      render text: exception, status: :unauthorized
    end
  end

  protected

  def load_labels
    @labels = Label.viewable_by(current_user).ordered
  end

  def set_locale
    @time_zones = ActiveSupport::TimeZone.all.map(&:name).sort
    @locales = []

    Dir.open("#{Rails.root}/config/locales").each do |file|
      unless ['.', '..'].include?(file)
        code = file[0...-4] # strip of .yml
        @locales << [I18n.translate(:language_name, locale: code), code]
      end
    end

    if user_signed_in? && !current_user.locale.blank?
      I18n.locale = current_user.locale
    else
      locale = http_accept_language.compatible_language_from(@locales)

      if Tenant.current_tenant.ignore_user_agent_locale? || locale.blank?
        I18n.locale = Tenant.current_tenant.default_locale
      else
        I18n.locale = locale
      end
    end
  end

  def load_tenant
    if request.subdomain.blank?
      Tenant.current_domain = request.domain
    else
      Tenant.current_domain = "#{request.subdomain}.#{request.domain}"
    end
  end
end
