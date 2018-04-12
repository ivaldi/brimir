class AddEmailTemplatesToTenant < ActiveRecord::Migration[4.2]
  def change
    unless column_exists? :tenants, :email_template_id
      add_reference :tenants, :email_template, index: true, foreign_key: true
    end
  end
end
