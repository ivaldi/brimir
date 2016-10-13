class AddEmailTemplatesToTenant < ActiveRecord::Migration
  def change
    add_reference :tenants, :email_template, index: true, foreign_key: true
  end
end
