class AddDraftToReply < ActiveRecord::Migration[4.2]
  def change
    add_column :replies, :draft, :boolean, default: false, null: false
  end
end
