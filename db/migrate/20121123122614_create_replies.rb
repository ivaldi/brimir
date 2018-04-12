class CreateReplies < ActiveRecord::Migration[4.2]
  def change
    create_table :replies do |t|
      t.text :content

      t.timestamps
    end
  end
end
