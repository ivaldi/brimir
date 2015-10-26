class AddDraftToReply < ActiveRecord::Migration
  def change
    add_column :replies, :draft, :boolean, default: false, null: false
  end
end
