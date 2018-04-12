class AddStartAndEndToSchedule < ActiveRecord::Migration[4.2]
  def change
    add_column :schedules, :start, :datetime
    add_column :schedules, :end, :datetime
  end
end
