class AddTimeConsumedToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :time_consumed, :integer, :default => 0
  end
end
