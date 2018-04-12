class CreateStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :statuses do |t|
      t.string :name

      t.timestamps


    end

    change_table :tickets do |t|
      t.integer :status_id
    end

    add_index :tickets, :status_id
  end
end
