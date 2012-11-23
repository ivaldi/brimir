class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies do |t|
      t.text :content

      t.timestamps
    end
  end
end
