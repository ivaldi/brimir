class CreateWelcomeMessages < ActiveRecord::Migration
  def change
    create_table :welcome_messages do |t|
      t.text :body
      t.string :subject
      t.belongs_to :tenant, index: true

      t.timestamps null: false
    end
  end
end
