class AddTypeToReplies < ActiveRecord::Migration[4.2]
  def change
    add_column :replies, :type, :string
  end
end
