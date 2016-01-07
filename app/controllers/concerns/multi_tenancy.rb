module MultiTenancy
  extend ActiveSupport::Concern
  protected
  def load_tenant
    if request.subdomain.blank?
      Tenant.current_domain = request.domain
    else
      Tenant.current_domain = "#{request.subdomain}.#{request.domain}"
    end
  end
end