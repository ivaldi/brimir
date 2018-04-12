class AddAgentAndSignatureToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :agent, :boolean
    add_column :users, :signature, :text
  end
end
