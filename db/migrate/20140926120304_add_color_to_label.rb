class AddColorToLabel < ActiveRecord::Migration
  def change
    add_column :labels, :color, :string
    Label.all.each do |label|
      label.assign_random_color
      label.save!
    end
  end
end
