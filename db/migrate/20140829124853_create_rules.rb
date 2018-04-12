class CreateRules < ActiveRecord::Migration[4.2]
  def change
    create_table :rules do |t|
      t.string :filter_field
      t.integer :filter_operation, null: false, default: 0
      t.string :filter_value
      t.integer :action_operation, null: false, default: 0
      t.string :action_value

      t.timestamps
    end
  end
end
