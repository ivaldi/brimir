class AddScheduleToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :schedule, index: true, foreign_key: true
  end
end
