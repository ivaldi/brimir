class CreateTickets < ActiveRecord::Migration[4.2]
  def change
    create_table :tickets do |t|
      t.string :from
      t.string :subject
      t.text :content

      t.timestamps
    end
  end
end
