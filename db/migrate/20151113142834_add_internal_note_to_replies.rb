class AddInternalNoteToReplies < ActiveRecord::Migration
  def change
    add_column :replies, :internal, :boolean, default: false, null: false
  end
end
