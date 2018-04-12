class AddColorToLabel < ActiveRecord::Migration[4.2]
  def change
    add_column :labels, :color, :string
    Label.all.each do |label|
      label.assign_random_color
      label.save!
    end
  end
end
