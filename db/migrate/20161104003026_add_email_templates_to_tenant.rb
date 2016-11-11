class AddEmailTemplatesToTenant < ActiveRecord::Migration
  def change
    unless column_exists? :tenants, :email_template_id
      add_reference :tenants, :email_template, index: true, foreign_key: true
    end
  end
end
