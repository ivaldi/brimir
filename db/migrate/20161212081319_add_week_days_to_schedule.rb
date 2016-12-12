class AddWeekDaysToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :monday, :boolean, default: true, null: false
    add_column :schedules, :tuesday, :boolean, default: true, null: false
    add_column :schedules, :wednesday, :boolean, default: true, null: false
    add_column :schedules, :thursday, :boolean, default: true, null: false
    add_column :schedules, :friday, :boolean, default: true, null: false
    add_column :schedules, :saturday, :boolean, default: false, null: false
    add_column :schedules, :sunday, :boolean, default: false, null: false
  end
end
