class AddDraftToEmailTemplate < ActiveRecord::Migration
  def change
    add_column :email_templates, :draft, :boolean, default: true, null: false
  end
end
