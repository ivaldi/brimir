class CreateEmailTemplates < ActiveRecord::Migration[4.2]
  def change
    create_table :email_templates do |t|
      t.string :name
      t.text :message
      t.integer :kind, null: false

      t.timestamps null: false
    end
  end
end
