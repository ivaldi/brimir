class AddDraftToEmailTemplate < ActiveRecord::Migration[4.2]
  def change
    add_column :email_templates, :draft, :boolean, default: true, null: false
  end
end
