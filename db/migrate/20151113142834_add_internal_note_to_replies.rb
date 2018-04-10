class AddInternalNoteToReplies < ActiveRecord::Migration[4.2]
  def change
    add_column :replies, :internal, :boolean, default: false, null: false
  end
end
