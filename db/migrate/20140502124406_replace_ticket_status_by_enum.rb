class ReplaceTicketStatusByEnum < ActiveRecord::Migration

  class OldStatus < ActiveRecord::Base
    self.table_name = 'statuses'
    has_many :tickets, foreign_key: 'status_id'
  end

  def change

    add_column :tickets, :status, :integer, null: false, default: 0

    OldStatus.all.each do |status|
      if status.name == 'Deleted'
        new_status = :deleted
      elsif status.name == 'Closed'
        new_status = :closed
      else
        new_status = :open
      end

      status.tickets.each do |t|
        t.status = new_status
        t.save
      end
    end

    remove_column :tickets, :status_id
    drop_table :statuses
    add_index :tickets, :status

  end
end
