class CreatePriorities < ActiveRecord::Migration[4.2]
  def change
    create_table :priorities do |t|
      t.string :name
      t.boolean :default, default: false

      t.timestamps
    end

    add_column :tickets, :priority_id, :integer
    add_index :tickets, :priority_id
  end
end
