class AddTimeZoneToUser < ActiveRecord::Migration
  def change
    add_column :users, :time_zone, :string, default: 'Amsterdam'
  end
end
