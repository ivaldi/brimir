class AddScheduleToUsers < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :schedule, index: true, foreign_key: true
  end
end
