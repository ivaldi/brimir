class CreateJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_join_table :tickets, :users do |t|
      # t.index [:ticket_id, :user_id]
      # t.index [:user_id, :ticket_id]
    end
  end
end
