class TicketPriorityToEnum < ActiveRecord::Migration

  class OldPriority < ActiveRecord::Base
    self.table_name = 'priorities'
    has_many :tickets, foreign_key: 'priority_id'
  end

  def change

    add_column :tickets, :priority, :integer, null: false, default: 0

    OldPriority.all.each do |priority|
      if priority.name == 'High'
        new_priority = :high
      elsif priority.name == 'Medium'
        new_priority = :medium
      elsif priority.name == 'Low'
        new_priority = :low
      else
        new_priority = :unknown
      end

      priority.tickets.each do |t|
        t.priority = new_priority
        t.save
      end
    end

    remove_column :tickets, :priority_id
    drop_table :priorities
    add_index :tickets, :priority

  end

end
