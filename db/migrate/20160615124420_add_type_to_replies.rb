class AddTypeToReplies < ActiveRecord::Migration
  def change
    add_column :replies, :type, :string
  end
end
