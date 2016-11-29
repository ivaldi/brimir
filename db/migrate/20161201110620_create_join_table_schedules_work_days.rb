class CreateJoinTableSchedulesWorkDays < ActiveRecord::Migration
  def change
    create_join_table :schedules, :work_days do |t|
      # t.index [:schedule_id, :work_day_id]
      # t.index [:work_day_id, :schedule_id]
    end
  end
end
